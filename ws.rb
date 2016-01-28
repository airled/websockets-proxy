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
    ws.onclose do
      puts 'Websocket closed'
    end

    conn = Bunny.new
    conn.start
    ch = conn.create_channel

    q = ch.queue("request", :auto_delete => true)
    x = ch.default_exchange

    q.subscribe do |delivery_info, metadata, payload|
      p JSON.parse(payload)
      # ws.send(payload)
    end
    
    ws.onmessage do |response|
      x.publish(response, :routing_key => 'response')
    end

  end #websocket
end #get
