require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
set :port, 3101

get '/' do
  request.websocket do |ws|
    ws.onopen do
      p 'Websocket opened'
      settings.sockets << ws
      p env
      # p "#{request.ip}:#{request.port}"
    end
    ws.onmessage do |response|
      p response
    end
    ws.onclose do
      settings.sockets.delete(ws)
      p 'Websocket closed'
    end
  end
end
