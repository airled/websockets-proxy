require 'sinatra'
require 'json'
require_relative '../config/models'

set :server, 'thin'
set :bind, '127.0.0.1'
set :port, 3102

def valid?(params)
  params.has_key?('email') &&
  params.has_key?('password') &&
  params.has_key?('profile') &&
  !Account[email: params['email']].nil? &&
  Account[email: params['email']].has_password?(params['password']) &&
  Account[email: params['email']].has_profile?(params['profile'])
end

post '/auth' do
  content_type :json
  if valid?(params)
    account = Account[email: params['email']]
    {'result' => 'ok', 'queue' => Profile[account_id: account.id, name: params['profile']].queue}.to_json
  else
    {'result' => 'failed'}.to_json
  end
end
