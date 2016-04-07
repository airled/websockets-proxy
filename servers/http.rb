require 'sinatra'
require 'sinatra/multi_route'
require_relative '../config/initializer'

set :server, 'thin'
set :bind, '127.0.0.1'
set :port, 3103

queuelist = Queuelist.new

def get_request_data(request_env)
  host = request_env['HTTP_HOST']
  resource = request_env['REQUEST_URI']
  url = host.include?(' ') ? host.split(' ')[1] : "http://#{host}#{resource}"
  {
    url: url,
    method: request_env['REQUEST_METHOD'],
    params: request_env['rack.request.form_vars'],
    headers: {
      'Cookie' => request_env['HTTP_COOKIE'],
      'User-Agent' => request_env['HTTP_USER_AGENT'],
      'Referer' => request_env['HTTP_REFERER'],
      'Accept' => request_env['HTTP_ACCEPT'],
      'Accept-Language' => request_env['HTTP_ACCEPT_LANGUAGE']
    }.delete_if { |key, value| value == nil }
  }.delete_if { |key, value| value == nil }
end

route :get, :post, :put, :delete, :head, '/*' do
  # personal_port = '3456'
  # personal_queue = '20bb1dded7add8a6fb'
  personal_port = request.env['HTTP_PERSONALPORT']
  personal_queue = request.env['HTTP_PERSONALQUEUE']
  account = Account[port: personal_port]

  if personal_port.nil? || personal_queue.nil? || account.nil?
    status 403
    body 'Invalid request'
  elsif !account.has_profile_with_queue?(personal_queue)
    status 404
    body 'No profile'
  else
    data_hash = get_request_data(request.env)
    answer = ''

    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    exchange = channel.default_exchange
    queue_exclusive = channel.queue('', exclusive: true)
    routing_key = personal_queue

    exchange.publish(data_hash.merge(reply_to: queue_exclusive.name).to_json, routing_key: routing_key)
    
    queue_exclusive.subscribe(block: true) do |delivery_info, metadata, payload|
      answer = JSON.parse(payload)
      delivery_info.consumer.cancel
    end
    
    connection.close
    
    status answer['status']
    answer['headers'].each_pair { |header_name, header_value| response[header_name] = header_value }
    content_type answer['headers']['Content-Type'].split(';')[0] if answer['headers']['Content-Type']
    answer['body']
  end

end
