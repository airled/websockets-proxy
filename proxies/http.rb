require 'sinatra'
require "bunny"

set :server, 'thin'
set :port, 3100

get '/' do

  answer = []

  if request.env['HTTP_USER_AGENT'] == 'curl'
    location = request.env['HTTP_LOCATION']

    conn = Bunny.new
    conn.start
    ch = conn.create_channel

    q = ch.queue("response", :auto_delete => true)
    x = ch.default_exchange

    x.publish(location, :routing_key => 'request')

    q.subscribe do |delivery_info, metadata, payload|
      answer << payload
    end

    conn.close
  end

  answer

end

