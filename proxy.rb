require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
set :port, 6666

get '/' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        ws.send("Hello World!")
        settings.sockets << ws
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets.delete(ws)
      end
    end
  elsif request.env['HTTP_USER_AGENT'] == 'curl'
    location = request.env['HTTP_LOCATION']
    EM.next_tick { settings.sockets[0].send(location) }
  else
    erb :index
  end
end
