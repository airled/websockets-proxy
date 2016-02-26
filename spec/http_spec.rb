require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../servers/http.rb', __FILE__

describe "HTTP server" do

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

  it "should add cookies to response" do
    cookies = "test1=test2\ntest3=test4"
    get '/'
    add_cookies_to_response(cookies, last_response)
    expect(last_response['Set-Cookie']).to include("test1=test2")
    expect(last_response['Set-Cookie']).to include("test3=test4")
  end

  it "should find activated port in port list" do
    PORTLIST = Redis.new(db: '14')
    PORTLIST.set('1234', 'test')
    expect(port_is_not_active?('1234')).to eql(false)
    PORTLIST.flushdb
  end

  it "should not find deactivated port in port list" do
    PORTLIST = Redis.new(db: '14')
    PORTLIST.set('1234', 'test')
    expect(port_is_not_active?('1235')).to eql(true)
    PORTLIST.flushdb
  end

  it "should return status 404 if personal port is not active" do
    PORTLIST = Redis.new(db: '14')
    PORTLIST.set('1234', 'test')
    get '/'
    personal_port = '1235'
    expect(last_response.status).to eql(404)
    PORTLIST.flushdb
  end

  it "should return warning message in body if personal port is not active" do
    PORTLIST = Redis.new(db: '14')
    PORTLIST.set('1234', 'test')
    get '/'
    personal_port = '1235'
    expect(last_response.body).to eql('No websocket for this port')
    PORTLIST.flushdb
  end

  # it "should return status 200 if personal port is active" do
  #   PORTLIST = Redis.new(db: '14')
  #   PORTLIST.set('1234', 'test')
  #   personal_port = '1234'
  #   get '/'
  #   # binding.pry
  #   expect(last_response.status).to eql(200)
  #   PORTLIST.flushdb
  # end

end
