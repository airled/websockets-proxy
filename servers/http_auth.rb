require 'sinatra'
require 'bcrypt'
require 'json'
require_relative '../models/account_model'

set :server, 'thin'
set :bind, '127.0.0.1'
set :port, 3103

post '/auth' do
  p request
  if !params.has_key?('email') ||
     !params.has_key?('password') ||
     Account[email: params['email']].nil? ||
     !Account[email: params['email']].has_password?(params['password'])
       {'result': 'failed'}.to_json
  else
    {'result': 'ok', 'queue': Account[email: params['email']].queue}.to_json
  end
end
