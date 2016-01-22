require 'sinatra'
require 'sinatra-websocket'
require "amqp"

set :server, 'thin'
set :sockets, []
set :port, 3101

get '/' do

  request.websocket do |ws|

    EventMachine.run do

      AMQP.connect(:host => '127.0.0.1') do |connection|
        channel = AMQP::Channel.new(connection)

        channel.queue("request", :auto_delete => true).subscribe do |payload|
          # EM.next_tick { settings.sockets[0].send(payload) }
          puts "//////////////////////////"
          puts "payload"
          puts "//////////////////////////"
        end

        ws.onopen do
          puts 'Websocket opened'
          settings.sockets << ws
        end
        ws.onmessage do |response|
          channel.direct("").publish response, :routing_key => "response"
        end
        ws.onclose do
          settings.sockets.delete(ws)
          puts 'Websocket closed'
        end
        
      end
    end

  end

end
