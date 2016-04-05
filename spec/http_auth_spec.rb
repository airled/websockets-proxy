require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../servers/http_auth.rb', __FILE__

describe 'Auth HTTP server' do

  before(:all) do
    DatabaseCleaner.clean
    @account_empty = Account.create(email: 'asd@asd.asd', crypted_password: make_crypted('zaqwsxcd'), role: "user", port: 1000)
    @account = Account.create(email: 'zxc@zxc.zxc', crypted_password: make_crypted('qwertyui'), role: "user", port: 234567)
    @profile1 = @account.add_profile(name: 'nekonekonyanya', queue: 'nyanqueue')
    @profile2 = @account.add_profile(name: 'mimimi', queue: 'ohhai')
  end

  it 'should not validate if the params are empty' do
    params = {}
    expect(valid_params?(params)).to eql(false)
  end

  it 'should not validate the params without a email' do
    params = {'password' => '12345678'}
    expect(valid_params?(params)).to eql(false)
  end

  it 'should not validate the params without a password' do
    params = {'email' => 'abc@abc.abc'}
    expect(valid_params?(params)).to eql(false)
  end

  it 'should validate if the params are right' do
    params = {'email' => 'abc@abc.abc', 'password' => '12345678'}
    expect(valid_params?(params)).to eql(true)
  end

  it 'should not validate if the account is nil' do
    params = {'email' => 'abc@abc.abc', 'password' => 'qwertyui'}
    expect(valid_account?(params)).to eql(false)
  end

  it 'should not validate if the password is not right' do
    params = {'email' => 'zxc@zxc.zxc', 'password' => '00000000'}
    expect(valid_account?(params)).to eql(false)
  end

  it 'should validate if the account exists and the password is right' do
    params = {'email' => 'zxc@zxc.zxc', 'password' => 'qwertyui'}
    expect(valid_account?(params)).to eql(true)
  end

  it '"/get_profiles" should return "failed" if there is no params at all' do
    post '/get_profiles'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_profiles" should return "failed" if there is no email param' do
    post '/get_profiles', 'password' => 'qwertyui' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_profiles" should return "failed" if there is no password param' do
    post '/get_profiles', 'email' => 'zxc@zxc.zxc'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_profiles" should return "failed" if there is no such account' do
    post '/get_profiles', 'email' => 'abc@abc.abc', 'password' => 'qwertyui'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_profiles" should return "failed" if the password is wrong' do
    post '/get_profiles', 'email' => 'zxc@zxc.zxc', 'password' => '123456789'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_profiles" should return "empty" if there are no profiles for this account' do
    post '/get_profiles', 'email' => 'asd@asd.asd', 'password' => 'zaqwsxcd'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('empty')
  end

  it '"/get_profiles" should return profiles if the params are right' do
    post '/get_profiles', 'email' => 'zxc@zxc.zxc', 'password' => 'qwertyui'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('ok')
    expect(JSON.parse(last_response.body)['profiles']).to eql(['nekonekonyanya', 'mimimi'])
  end

  it '"/get_queue" should return "failed" if there is no params at all' do
    post '/get_queue'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_queue" should return "failed" if there is no email param' do
    post '/get_queue', 'password' => 'qwertyui', 'profile' => 'mimimi' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_queue" should return "failed" if there is no password param' do
    post '/get_queue', 'email' => 'zxc@zxc.zxc', 'profile' => 'mimimi' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_queue" should return "failed" if there is no profile param' do
    post '/get_queue', 'email' => 'zxc@zxc.zxc', 'password' => 'qwertyui' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_queue" should return "failed" if there is no such account' do
    post '/get_queue', 'email' => '1zxc1@zxc.zxc', 'password' => 'qwertyui', 'profile' => 'mimimi' 
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_queue" should return "failed" if the password is wrong' do
    post '/get_queue', 'email' => 'zxc@zxc.zxc', 'password' => '123456789', 'profile' => 'mimimi'
    expect(last_response.status).to eql(400)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it '"/get_queue" should return "no_profile" if the profile does not exist for this account' do
    post '/get_queue', 'email' => 'zxc@zxc.zxc', 'password' => 'qwertyui', 'profile' => 'zizizi'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('no_profile')
  end

  it '"/get_queue" should return queue name everything is right' do
    post '/get_queue', 'email' => 'zxc@zxc.zxc', 'password' => 'qwertyui', 'profile' => 'mimimi' 
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('ok')
    expect(JSON.parse(last_response.body)['queue']).to eql('ohhai')
  end

end
