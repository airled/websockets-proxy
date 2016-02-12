require 'sinatra'
require 'sinatra-websocket'
require "bunny"
require 'json'

set :server, 'thin'
set :port, 3101

get '/' do
  request.websocket do |ws|

    ws.onopen do
      puts 'Websocket opened'
    end

    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    queue = channel.queue("request")
    exchange = channel.default_exchange

    queue.subscribe do |delivery_info, metadata, payload|
      ws.send(payload)
    end

    ws.onmessage do |response|
      reply_to = JSON.parse(response)['reply_to']
      exchange.publish(response, :routing_key => reply_to)
    end

    ws.onclose do
      puts 'Websocket closed'
      connection.close
    end

  end #websocket
end #get
