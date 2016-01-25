require 'sinatra'
require 'sinatra-websocket'
# require "amqp"
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
      p "Got #{payload}"
      settings.sockets[0].send(payload)
    end
    
    ws.onmessage do |response|
      p response
      # channel.direct("").publish response, :routing_key => "response"
      x.publish(response, :routing_key => 'response')
    end

    # EventMachine.run do

    #   AMQP.connect(:host => '127.0.0.1') do |connection|
    #     channel = AMQP::Channel.new(connection)

    #     channel.queue("request", :auto_delete => true).subscribe do |payload|
    #       puts "//////////////////////////"
    #       puts "#{payload}"
    #       puts "//////////////////////////"
    #       EM.next_tick { settings.sockets[0].send(payload) }
    #     end

    #   end #connection
    # end #eventmachine

  end #websocket
end #get
