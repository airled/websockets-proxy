require 'sinatra'
require "sinatra/multi_route"
require "bunny"
require 'json'

set :server, 'thin'
set :port, 3100

route :get, :post, :put, :patch, :delete, :head, :options, '/*' do

  # p request.env

  # type = 
  #   if request.env['REQUEST_URI'].include?('.css')
  #     "text/css"
  #   end

  # answer = ''

  host = request.env['HTTP_HOST']
  resource = request.env['REQUEST_URI']
  method = request.env['REQUEST_METHOD']
  query = request.env['rack.request.form_hash']
  
  location = "http://#{host}#{resource}"

  data = {location: location, method: method, query: query}.to_json

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

  content_type type
  answer

end
