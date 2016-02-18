require 'sinatra'
require 'sinatra-websocket'
require "bunny"
require 'json'

set :server, 'thin'
set :port, 3101

def authenticate(hash)
  if hash['login'] == 'testlogin' && hash['password'] == 'testpassword'
    true
  else
    false
  end
end

get '/' do

  not_authenticated = true
  queue_name = ''

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
      if not_authenticated
        init = JSON.parse(response)
        if init.has_key?('login') && init.has_key?('password') && authenticate(init)
          ws.send('auth_ok')
          queue_name = '123'
          not_authenticated = false
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
    end

  end #websocket
end #get
