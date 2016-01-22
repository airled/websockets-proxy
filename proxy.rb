require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :port, 3101
set :sockets, []

get '/' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        p 'Websocket opened'
        settings.sockets << ws
      end
      ws.onmessage do |response|
        p response
      end
      ws.onclose do
        settings.sockets.delete(ws)
        p 'Websocket closed'
      end
    end
  elsif request.env['HTTP_USER_AGENT'] == 'curl'
    location = request.env['HTTP_LOCATION']
    EM.next_tick { settings.sockets[0].send(location) }
  end

end
