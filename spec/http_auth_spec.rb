require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../servers/http_auth.rb', __FILE__

describe 'Auth HTTP server' do

  before(:all) do
    @account = Account.create(
      email: 'abc@abc.abc',
      crypted_password: ::BCrypt::Password.create('1234567890'),
      role: 'user',
      confirmed: false,
      active: false,
      queue: '111',
      port: 234567
    )
  end

  it 'should return "failed" if there is no params at all' do
    post '/auth'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if there is no email-param' do
    post '/auth', password: '1234567890'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if there is no password-param' do
    post '/auth', email: 'abc@abc.abc'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if there is no such account' do
    post '/auth', email: 'abc@abc.abc1', password: '1234567890'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return "failed" if there is the password is wrong' do
    post '/auth', email: 'abc@abc.abc', password: '12345678900'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('failed')
  end

  it 'should return queue name if all the params are right' do
    post '/auth', email: 'abc@abc.abc', password: '1234567890'
    expect(last_response.status).to eql(200)
    expect(last_response.content_type).to eql('application/json')
    expect(JSON.parse(last_response.body)['result']).to eql('ok')
    expect(JSON.parse(last_response.body)['queue']).to eql('111')
  end

  after(:all) do
    @account.destroy
  end

end
