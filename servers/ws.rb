require 'sinatra'
require 'sinatra-websocket'
require_relative '../config/initializer'

set :server, 'thin'
set :port, 3101

portlist = Portlist.new
portlist.clear

def valid?(init_message)
  init_message.has_key?('email') && init_message.has_key?('password')
end

def authenticate(init_message)
  account = Account[email: init_message['email']]
  if !account.nil? && account.has_password?(init_message['password']) && account.confirmed?
    account
  else
    false
  end
end

get '/' do
  request.websocket do |ws|
    authenticated = false
    account = nil

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
          ws.send('auth_ok')
          p "Queue '#{account.queue}' is bound up with port '#{account.port}'"
          authenticated = true
          portlist.bind(account.port, account.queue)
          account.activate

          queue = channel.queue(account.queue)
          queue.subscribe do |delivery_info, metadata, payload|
            ws.send(payload)
          end
          
        else
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
      portlist.unbind(account.port) && account.deactivate if account
    end

  end #websocket
end #get
