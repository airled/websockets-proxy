require 'sinatra'
require 'sinatra-websocket'
require "bunny"

set :server, 'thin'
set :sockets, []
set :port, 3101

get '/' do

  request.websocket do |ws|

    ws.onopen do
      puts 'Websocket opened'
      settings.sockets << ws
    end
    ws.onclose do
      settings.sockets.delete(ws)
      puts 'Websocket closed'
    end

    conn = Bunny.new
    conn.start
    ch = conn.create_channel

    q = ch.queue("request", :auto_delete => true)
    x = ch.default_exchange

    q.subscribe do |delivery_info, metadata, payload|
      settings.sockets[0].send(payload)
      p payload
    end
    
    ws.onmessage do |response|
      x.publish(response, :routing_key => 'response')
    end

  end #websocket
end #get
