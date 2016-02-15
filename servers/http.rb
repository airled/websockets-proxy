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
  query = request_env['rack.request.form_vars']
  cookies = request_env['HTTP_COOKIE']
  agent = request_env['HTTP_USER_AGENT']
  referer = request_env['HTTP_REFERER']
  url = host.include?(' ') ? host.split(' ')[1] : "http://#{host}#{resource}"
  {
    url: url,
    method: method,
    query: query,
    cookies: cookies,
    agent: agent,
    referer: referer
  }
end

route :get, :post, :put, :delete, :head, '/*' do
  
  data_hash = get_data(request.env)
  answer = ''

  connection = Bunny.new
  connection.start
  channel = connection.create_channel
  queue_exclusive = channel.queue("", :exclusive => true)
  exchange = channel.default_exchange

  exchange.publish(data_hash.merge(reply_to: queue_exclusive.name).to_json, :routing_key => 'request')
  
  queue_exclusive.subscribe(:block => true) do |delivery_info, metadata, payload|
    answer = JSON.parse(payload)
    delivery_info.consumer.cancel
  end
  
  connection.close

  content_type answer['type'].split(';')[0]
  response.set_cookie(answer['cookies'].split('=')[0], :value => answer['cookies'].split('=')[1]) if answer['cookies']
  answer['text']

end
