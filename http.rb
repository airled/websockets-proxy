require 'sinatra'
require "bunny"

set :server, 'thin'
set :port, 3100

get '/*' do

  type = 
    if request.env['REQUEST_URI'].include?('.css')
      "text/css"
    end

  answer = ''

  host_to = request.env['HTTP_HOST']
  resource_to = request.env['REQUEST_URI']
  method = request.env['REQUEST_METHOD']
  
  location = "http://#{host_to}#{resource_to}"

  conn = Bunny.new
  conn.start
  ch = conn.create_channel

  q = ch.queue("response", :auto_delete => true)
  x = ch.default_exchange

  x.publish(location, :routing_key => 'request')

  q.subscribe(:block => true) do |delivery_info, metadata, payload|
    # puts payload
    answer = payload
    delivery_info.consumer.cancel
  end
  
  conn.close

  content_type type
  answer

end
