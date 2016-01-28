require 'sinatra'
require "sinatra/multi_route"
require "bunny"
require 'json'

set :server, 'thin'
set :port, 3100

route :get, :post, :put, :patch, :delete, :head, :options, '/*' do
  answer = ''
  req = request.env
  # p req

  host = req['HTTP_HOST']
  resource = req['REQUEST_URI']
  method = req['REQUEST_METHOD']
  query = req['rack.request.form_hash']
  cookies = req['HTTP_COOKIE']
  
  location = "http://#{host}#{resource}"

  data = {location: location, method: method, query: query, cookies: cookies}.to_json

  # puts data.colorize(:red)
  # puts JSON.parse(data)

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

  content_type "text/css" if req['REQUEST_URI'].include?('.css')
  answer

end
