require 'sinatra'
require 'sinatra-websocket'
require_relative '../config/initializer'

set :server, 'thin'
set :bind, '127.0.0.1'
set :port, 3101

queuelist = Queuelist.new
queuelist.clear

def valid?(init_message)
  init_message.has_key?('email') &&
  init_message.has_key?('password') &&
  init_message.has_key?('profile')
end

def authenticate(init_message)
  account = Account[email: init_message['email']]
  if !account.nil? && account.has_password?(init_message['password']) && account.port
    account
  else
    false
  end
end

get '/' do
  request.websocket do |ws|
    authenticated = false
    account = nil
    profile = nil
    profile_queue = nil
    activated = false

    ws.onopen do
      puts 'Websocket opened'
      ws.send('login')
    end

    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    exchange = channel.default_exchange

    ws.onmessage do |response|
      if !authenticated
        init_message = JSON.parse(response)
        if valid?(init_message) && account = authenticate(init_message)
          if account.has_profile?(init_message['profile'])
            profile = Profile[account_id: account.id, name: init_message['profile']]
            profile_queue = profile.queue
            if !queuelist.has_queue?(profile_queue)
              ws.send('auth_ok')
              p "Queue \'#{profile_queue}\' for profile \'#{profile.name}\' of user \'#{account.email}\'"
              authenticated = true
              queuelist.set(profile_queue)
              activated = true
              profile.activate
              queue = channel.queue(profile_queue)
              queue.subscribe do |delivery_info, metadata, payload|
                ws.send(payload)
              end
            else
              ws.send('busy_profile')
              ws.close_websocket
            end
          else
            ws.send('wrong_profile')
            ws.close_websocket
          end
        else
          ws.send('auth_failed')
          ws.close_websocket
        end
      else
        reply_to = JSON.parse(response)['reply_to']
        exchange.publish(response, routing_key: reply_to)
      end
    end

    ws.onclose do
      puts 'Websocket closed'
      connection.close
      queuelist.unset(profile_queue) && profile.deactivate if activated == true
    end

  end #websocket
end #get
