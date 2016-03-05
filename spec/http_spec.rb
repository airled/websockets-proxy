require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../servers/http.rb', __FILE__

describe "HTTP server" do

  before(:all) do
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

  # it "should return status 404 if personal port is not active" do
  #   get '/'
  #   personal_port = '1235'
  #   expect(last_response.status).to eql(404)
  # end

  # it "should return warning message in body if personal port is not active" do
  #   get '/'
  #   personal_port = '1235'
  #   expect(last_response.body).to eql('No websocket for this port')
  # end

  # it "should return status 200 if personal port is active" do
  #   personal_port = '1234'
  #   get '/'
  #   # binding.pry
  #   expect(last_response.status).to eql(200)
  # end

  after(:all) do
  end

end
