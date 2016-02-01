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
  url = "http://#{host}#{resource}"
  {url: url, method: method, query: query, cookies: cookies, agent: agent, referer: referer}
end

route :get, :post, :put, :delete, :head, '/*' do
 
  data_hash = get_data(request.env)

  conn = Bunny.new
  conn.start
  ch = conn.create_channel
  q = ch.queue("", :exclusive => true, :auto_delete => true)
  x = ch.default_exchange

  x.publish(data_hash.merge(reply_to: q.name).to_json, :routing_key => 'request')
  
  answer = ''

  q.subscribe(:block => true) do |delivery_info, metadata, payload|
    answer = JSON.parse(payload)
    delivery_info.consumer.cancel
  end
  
  conn.close

  content_type answer['type']
  response.set_cookie(answer['cookies'].split('=')[0], :value => answer['cookies'].split('=')[1]) if answer['cookies']
  answer['text']

end
