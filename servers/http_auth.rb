require 'sinatra'
require 'json'
require_relative '../config/models'

set :server, 'thin'
set :bind, '127.0.0.1'
set :port, 3102

def valid_params?(params)
  params.has_key?('email') && params.has_key?('password') && params.has_key?('profile')
end

def valid_account?(params)
  account = Account[email: params['email']]
  !account.nil? && account.has_password?(params['password']) && account.has_profile?(params['profile'])
end

post '/auth' do
  content_type :json
  if valid_params?(params) && valid_account?(params)
    account = Account[email: params['email']]
    profile = Profile[account_id: account.id, name: params['profile']]
    {result: 'ok', queue: profile.queue}.to_json
  else
    status 400
    {result: 'failed'}.to_json
  end
end
