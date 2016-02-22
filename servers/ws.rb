require 'sinatra'
require 'sinatra-websocket'
require "bunny"
require 'json'
require 'bcrypt'
require_relative '../account_model'

set :server, 'thin'
set :port, 3101

def authenticate(hash)
  account = Account[email: hash['email']]
  if account.nil?
    false
  else
    ::BCrypt::Password.new(account.crypted_password) == hash['password'] ? account : false
  end
end

get '/' do
  authenticated = false
  queue_name = ''
  account = ''

  request.websocket do |ws|

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
        if init_message.has_key?('email') && init_message.has_key?('password') && authenticate(init_message)
          ws.send('auth_ok')
          account = authenticate(init_message)
          queue_name = account.queue
          port = account.port
          p "Queue '#{queue_name}' is bound up with port '#{port}'"
          authenticated = true
          account.update(active: true)
          queue = channel.queue(queue_name)

          queue.subscribe do |delivery_info, metadata, payload|
            ws.send(payload)
          end
          
        else
          ws.close_websocket
        end
      else
        reply_to = JSON.parse(response)['reply_to']
        exchange.publish(response, :routing_key => reply_to)
      end
    end

    ws.onclose do
      puts 'Websocket closed'
      connection.close
      account.update(active: false)
    end

  end #websocket
end #get
