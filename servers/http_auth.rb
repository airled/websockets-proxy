require 'sinatra'
require 'json'
require_relative '../config/models'

set :server, 'thin'
set :bind, '127.0.0.1'
set :port, 3102

def valid_params?(params)
  params.has_key?('email') && params.has_key?('password')
end

def valid_account?(params)
  account = Account[email: params['email']]
  !account.nil? && account.has_password?(params['password'])
end

post '/get_profiles' do
  content_type :json
  if valid_params?(params) && valid_account?(params)
    account = Account[email: params['email']]
    profiles = Profile.where(account_id: account.id).map(:name)
    if profiles.empty? || profiles == nil
      {result: 'empty'}.to_json
    else
      {result: 'ok', profiles: profiles}.to_json
    end
  else
    status 400
    {result: 'failed'}.to_json
  end
end

post '/get_queue' do
  content_type :json
  if params[:profile] && valid_params?(params) && valid_account?(params)
    account = Account[email: params['email']]
    profile = Profile[account_id: account.id, name: params['profile']]
    if profile
      {result: 'ok', queue: profile.queue}.to_json
    else
      {result: 'no_profile'}.to_json
    end
  else
    status 400
    {result: 'failed'}.to_json
  end
end
