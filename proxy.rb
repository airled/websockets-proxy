require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

get '/' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        p msg
      end
      ws.onclose do
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

# get '/frame.html' do
#   erb :frame
# end
