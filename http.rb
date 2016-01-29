require 'sinatra'
require "sinatra/multi_route"
require "bunny"
require 'json'

set :server, 'thin'
set :port, 3100

def get_data(request_env)
  host = request_env['HTTP_HOST']
  resource = request_env['REQUEST_URI']
  method = request_env['REQUEST_METHOD']
  query = request_env['rack.request.form_hash']
  cookies = request_env['HTTP_COOKIE']
  location = "http://#{host}#{resource}"
  {location: location, method: method, query: query, cookies: cookies}
end

route :get, :post, :put, :patch, :delete, :head, :options, '/*' do
  # p params
  # data = get_data(request.env)
  # p data
  answer = ''
  data = get_data(request.env).to_json

  conn = Bunny.new
  conn.start
  ch = conn.create_channel

  q = ch.queue("response", :auto_delete => true)
  x = ch.default_exchange

  x.publish(data, :routing_key => 'request')

  q.subscribe(:block => true) do |delivery_info, metadata, payload|
    answer = payload
    delivery_info.consumer.cancel
  end
  
  conn.close

  content_type "text/css" if request.env['REQUEST_URI'].include?('.css')
  answer

end
