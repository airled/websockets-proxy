require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../servers/http.rb', __FILE__
require File.expand_path '../../lib/portlist.rb', __FILE__

describe "HTTP server" do

  before(:all) do
    @portlist = Portlist.new
    @account = Account.create(
      :email => 'mytest@mytest.ru',
      :crypted_password => ::BCrypt::Password.create('supersecret'),
      :role => "user",
      :confirmed => true,
      :active => false,
      :queue => '111',
      :port => 234567
    )
  end

  it "should build proper url from request environment directly from thin" do
    request_env = {'HTTP_HOST' => '1.1.1.1:1111', 'REQUEST_URI' => '/test'}
    get_request_data(request_env)
    expect(get_request_data(request_env)[:url]).to eql('http://1.1.1.1:1111/test')
  end

  it "should build proper url from request environment via nginx" do
    request_env = {'HTTP_HOST' => 'test http://1.1.1.1:1111/test test', 'REQUEST_URI' => '/test'}
    get_request_data(request_env)
    expect(get_request_data(request_env)[:url]).to eql('http://1.1.1.1:1111/test')
  end

  it "should return 403 if there is no special headers" do
    get '/'
    expect(last_response.status).to eql(403)
    expect(last_response.body).to eq('Invalid request')
  end

  it "should return 403 if there is no personal port header" do
    get '/', {}, {'HTTP_PERSONALQUEUE' => '111'}
    expect(last_response.status).to eql(403)
    expect(last_response.body).to eq('Invalid request')
  end

  it "should return 403 if there is no personal queue header" do
    get '/', {}, {'HTTP_PERSONALPORT' => 234567}
    expect(last_response.status).to eql(403)
    expect(last_response.body).to eq('Invalid request')
  end

  it "should return 404 if all the special headers exists but port is not active" do
    get '/', {}, {'HTTP_PERSONALPORT' => 234567, 'HTTP_PERSONALQUEUE' => '111'}
    expect(last_response.status).to eql(404)
    expect(last_response.body).to include('No websocket for this port')
  end

  it "should return 403 if all the special headers exists, but queue is incorrect for this port" do
    @portlist.bind(@account.port, @account.queue)
    get '/', {}, {'HTTP_PERSONALPORT' => 234567, 'HTTP_PERSONALQUEUE' => '1111'}
    expect(last_response.status).to eql(403)
    expect(last_response.body).to eq('Invalid request data')
  end

  it "should got request data" do
    testenv = {
      'HTTP_PERSONALPORT' => 234567,
      'HTTP_PERSONALQUEUE' => '111',
      'HTTP_HOST' => 'hiimhost',
      'REQUEST_URI' => '/testuri',
      'REQUEST_METHOD' => 'testmethod',
      'rack.request.form_vars' => 'foo=bar',
      'HTTP_COOKIE' => 'testcookie=testvalue',
      'HTTP_USER_AGENT' => 'testuseragent',
      'HTTP_REFERER' => 'testreferer'
    }
    expect(get_request_data(testenv)).to eq({
      url: 'http://hiimhost/testuri',
      method: 'testmethod',
      query: 'foo=bar',
      cookies: 'testcookie=testvalue',
      agent: 'testuseragent',
      referer: 'testreferer'
    })
  end

  it "return result" do
    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    exchange = channel.default_exchange
    queue = channel.queue(@account.queue)
    queue.subscribe do |delivery_info, metadata, payload|
      reply_to = JSON.parse(payload)['reply_to']
      response = {'type' => 'text/html', 'cookies' => 'testcookies', 'text' => 'testtext'}.to_json
      exchange.publish(response, routing_key: reply_to)
    end
    @portlist.bind(@account.port, @account.queue)
    get '/', {}, {
      'HTTP_PERSONALPORT' => 234567,
      'HTTP_PERSONALQUEUE' => '111',
      'HTTP_HOST' => 'hiimhost',
      'REQUEST_URI' => '/testuri',
      'rack.request.form_vars' => 'foo=bar',
      'HTTP_COOKIE' => 'testcookie=testvalue',
      'HTTP_USER_AGENT' => 'testuseragent',
      'HTTP_REFERER' => 'testreferer'
    }
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('text/html;charset=utf-8')
    expect(last_response.headers['Set-Cookie']).to eq('testcookies')
    expect(last_response.body).to eq('testtext')
    connection.close
  end

  after(:all) do
    @account.destroy
    @portlist.clear
  end

end
