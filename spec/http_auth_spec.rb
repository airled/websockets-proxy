require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../servers/http_auth.rb', __FILE__

describe 'Auth HTTP server' do

  before(:all) do
    @account = Account.create(
      email: 'abc@abc.abc',
      crypted_password: ::BCrypt::Password.create('12345678'),
      role: 'user',
      port: 234567
    )
    @profile = @account.add_profile(name: 'myprofile', queue: 'testqueue', active: false)
  end

  it 'should not validate if the params are empty' do
    params = {}
    expect(valid_params?(params)).to eql(false)
  end

  it 'should not validate the params without a email' do
    params = {'password' => '12345678', 'profile' => 'myprofile'}
    expect(valid_params?(params)).to eql(false)
  end

  it 'should not validate the params without a password' do
    params = {'email' => 'abc@abc.abc', 'profile' => 'myprofile'}
    expect(valid_params?(params)).to eql(false)
  end

  it 'should not validate the params without a profile' do
    params = {'email' => 'abc@abc.abc', 'password' => '12345678'}
    expect(valid_params?(params)).to eql(false)
  end

  it 'should validate if the params are right' do
    params = {'email' => 'abc@abc.abc', 'password' => '12345678', 'profile' => 'myprofile'}
    expect(valid_params?(params)).to eql(true)
  end

  it 'should not validate if the account is nil' do
    params = {'email' => 'abc1@abc.abc', 'password' => '12345678', 'profile' => 'myprofile'}
    expect(valid_account?(params)).to eql(false)
  end

  it 'should not validate if the password is not right' do
    params = {'email' => 'abc@abc.abc', 'password' => '00000000', 'profile' => 'myprofile'}
    expect(valid_account?(params)).to eql(false)
  end

  it 'should not validate if the profile does not exist for this account' do
    params = {'email' => 'abc@abc.abc', 'password' => '12345678', 'profile' => 'mimimi'}
    expect(valid_account?(params)).to eql(false)
  end

  it 'should return "failed" if there is no params at all' do
    post '/auth'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if there is no email param' do
    post '/auth', 'password' => '12345678', 'profile' => 'myprofile' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if there is no password param' do
    post '/auth', 'email' => 'abc@abc.abc', 'profile' => 'myprofile' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if there is no profile param' do
    post '/auth', 'email' => 'abc@abc.abc', 'password' => '12345678' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if there is no such account' do
    post '/auth', 'email' => 'abc@abc.abc1', 'password' => '12345678', 'profile' => 'myprofile' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if the password is wrong' do
    post '/auth', 'email' => 'abc@abc.abc', 'password' => '123456789', 'profile' => 'myprofile'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if the profile does not exist for this account' do
    post '/auth', 'email' => 'abc@abc.abc', 'password' => '12345678', 'profile' => 'nilnilnil'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return queue name in json if the params are right' do
    post '/auth', 'email' => 'abc@abc.abc', 'password' => '12345678', 'profile' => 'myprofile' 
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('ok')
    expect(JSON.parse(last_response.body)['queue']).to eql('testqueue')
  end

  after(:all) do
    @account.destroy
    @profile.destroy
  end

end
