# require File.expand_path '../spec_helper.rb', __FILE__
# require File.expand_path '../../servers/http.rb', __FILE__
# require File.expand_path '../../lib/queuelist.rb', __FILE__

# describe "HTTP server" do

#   before(:all) do
#     @queuelist = Queuelist.new
#     @account = Account.create(
#       :email => 'testmy@testmy.my',
#       :crypted_password => ::BCrypt::Password.create('supersecret'),
#       :role => "user",
#       :port => 234567
#     )
#     @profile = @account.add_profile(name: 'profilemy', queue: 'queuetest', active: false)
#   end

#   it "should build proper url from request environment directly from thin" do
#     request_env = {'HTTP_HOST' => '1.1.1.1:1111', 'REQUEST_URI' => '/test'}
#     get_request_data(request_env)
#     expect(get_request_data(request_env)[:url]).to eql('http://1.1.1.1:1111/test')
#   end

#   it "should build proper url from request environment via nginx" do
#     request_env = {'HTTP_HOST' => 'test http://1.1.1.1:1111/test test', 'REQUEST_URI' => '/test'}
#     get_request_data(request_env)
#     expect(get_request_data(request_env)[:url]).to eql('http://1.1.1.1:1111/test')
#   end

#   it "should return 403 if there is no special headers" do
#     get '/'
#     expect(last_response.status).to eql(403)
#     expect(last_response.body).to eq('Invalid request')
#   end

#   it "should return 403 if there is no personal port header" do
#     get '/', {}, {'HTTP_PERSONALQUEUE' => '111'}
#     expect(last_response.status).to eql(403)
#     expect(last_response.body).to eq('Invalid request')
#   end

#   it "should return 403 if there is no personal queue header" do
#     get '/', {}, {'HTTP_PERSONALPORT' => 234567}
#     expect(last_response.status).to eql(403)
#     expect(last_response.body).to eq('Invalid request')
#   end

#   it "should return 404 if all the special headers exists but port is not active" do
#     get '/', {}, {'HTTP_PERSONALPORT' => 234567, 'HTTP_PERSONALQUEUE' => '111'}
#     expect(last_response.status).to eql(404)
#     expect(last_response.body).to eq('No websocket')
#   end

#   it "should got proper request data" do
#     testenv = {
#       'HTTP_PERSONALPORT' => 234567,
#       'HTTP_PERSONALQUEUE' => '111',
#       'HTTP_HOST' => 'hiimhost',
#       'REQUEST_URI' => '/testuri',
#       'REQUEST_METHOD' => 'testmethod',
#       'rack.request.form_vars' => 'foo=bar',
#       'HTTP_COOKIE' => 'testcookie=testvalue',
#       'HTTP_USER_AGENT' => 'testuseragent',
#       'HTTP_REFERER' => 'testreferer',
#       'HTTP_ACCEPT' => 'testaccept',
#       'HTTP_ACCEPT_LANGUAGE' => 'testrru'
#     }
#     expect(get_request_data(testenv)).to eq({
#       url: 'http://hiimhost/testuri',
#       method: 'testmethod',
#       params: 'foo=bar',
#       headers: {
#         'Cookie' => 'testcookie=testvalue',
#         'User-Agent' => 'testuseragent',
#         'Referer' => 'testreferer',
#         'Accept' => 'testaccept',
#         'Accept-Language' => 'testrru' 
#       }
#     })
#   end

#   it "should not include nil headers into request data" do
#     testenv = {
#       'HTTP_PERSONALPORT' => 234567,
#       'HTTP_PERSONALQUEUE' => '111',
#       'HTTP_HOST' => 'hiimhost',
#       'REQUEST_URI' => '/testuri',
#       'REQUEST_METHOD' => 'testmethod',
#       'rack.request.form_vars' => 'foo=bar',
#       'HTTP_COOKIE' => 'testcookie=testvalue',
#       'HTTP_USER_AGENT' => 'testuseragent',
#       'HTTP_REFERER' => nil,
#       'HTTP_ACCEPT' => 'testaccept',
#       'HTTP_ACCEPT_LANGUAGE' => 'testrru'
#     }
#     expect(get_request_data(testenv)).to eq({
#       url: 'http://hiimhost/testuri',
#       method: 'testmethod',
#       params: 'foo=bar',
#       headers: {
#         'Cookie' => 'testcookie=testvalue',
#         'User-Agent' => 'testuseragent',
#         'Accept' => 'testaccept',
#         'Accept-Language' => 'testrru' 
#       }
#     })
#   end

#   it "should not include nil params into request data" do
#     testenv = {
#       'HTTP_PERSONALPORT' => 234567,
#       'HTTP_PERSONALQUEUE' => '111',
#       'HTTP_HOST' => 'hiimhost',
#       'REQUEST_URI' => '/testuri',
#       'REQUEST_METHOD' => 'testmethod',
#       'rack.request.form_vars' => nil,
#       'HTTP_COOKIE' => 'testcookie=testvalue',
#       'HTTP_USER_AGENT' => 'testuseragent',
#       'HTTP_REFERER' => 'myreferer',
#       'HTTP_ACCEPT' => 'testaccept',
#       'HTTP_ACCEPT_LANGUAGE' => 'testrru'
#     }
#     expect(get_request_data(testenv)).to eq({
#       url: 'http://hiimhost/testuri',
#       method: 'testmethod',
#       headers: {
#         'Cookie' => 'testcookie=testvalue',
#         'User-Agent' => 'testuseragent',
#         'Accept' => 'testaccept',
#         'Accept-Language' => 'testrru' ,
#         'Referer' => 'myreferer'
#       }
#     })
#   end

#   it "return correct result" do
#     connection = Bunny.new
#     connection.start
#     channel = connection.create_channel
#     exchange = channel.default_exchange
#     queue = channel.queue(@profile.queue)
#     queue.subscribe do |delivery_info, metadata, payload|
#       reply_to = JSON.parse(payload)['reply_to']
#       response = {
#         'status': 201,
#         'headers':{
#           'Content-Type' => 'text/html;',
#           'Set-Cookie' => 'test=cookies'
#         },
#         'body' => 'testtext'
#       }.to_json
#       exchange.publish(response, routing_key: reply_to)
#     end
#     @queuelist.set(@profile.queue)
#     get '/', {}, {
#       'HTTP_PERSONALPORT' => 234567,
#       'HTTP_PERSONALQUEUE' => 'queuetest'
#     }
#     expect(last_response.status).to eq(201)
#     expect(last_response.content_type).to eq('text/html;charset=utf-8')
#     expect(last_response.headers['Set-Cookie']).to eq('test=cookies')
#     expect(last_response.body).to eq('testtext')
#     connection.close
#   end

#   after(:all) do
#     @account.destroy
#     @profile.destroy
#     @queuelist.clear
#   end

# end
