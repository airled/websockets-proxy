require 'sinatra'
require "sinatra/multi_route"
require "bunny"
require 'json'
require 'redis'
require_relative '../account_model'

set :server, 'thin'
set :port, 3102

PORTLIST = Redis.new(db: '15')

def get_request_data(request_env)
  host = request_env['HTTP_HOST']
  resource = request_env['REQUEST_URI']
  url = host.include?(' ') ? host.split(' ')[1] : "http://#{host}#{resource}"
  {
    url: url,
    method: request_env['REQUEST_METHOD'],
    query: request_env['rack.request.form_vars'],
    cookies: request_env['HTTP_COOKIE'],
    agent: request_env['HTTP_USER_AGENT'],
    referer: request_env['HTTP_REFERER']
  }
end

def port_is_not_active?(port)
  PORTLIST.get(port).nil?
end

route :get, :post, :put, :delete, :head, '/*' do
  
  personal_port = request.env['HTTP_PERSONALPORT']
  if port_is_not_active?(personal_port)
    status 404
    body 'No websocket for this port'
  else
    data_hash = get_request_data(request.env)
    answer = ''

    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    exchange = channel.default_exchange
    queue_exclusive = channel.queue("", :exclusive => true)
    routing_key = Account[port: personal_port].queue

    exchange.publish(data_hash.merge(reply_to: queue_exclusive.name).to_json, :routing_key => routing_key)
    
    queue_exclusive.subscribe(:block => true) do |delivery_info, metadata, payload|
      answer = JSON.parse(payload)
      delivery_info.consumer.cancel
    end
    
    connection.close

    content_type answer['type'].split(';')[0]
    response.headers['Set-Cookie'] = answer['cookies'] if answer['cookies']
    answer['text']
  end

end
