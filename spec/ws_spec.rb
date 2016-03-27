# require File.expand_path '../spec_helper.rb', __FILE__
# require File.expand_path '../../servers/ws.rb', __FILE__

# describe "Websocket server" do
#   PORTLIST = Redis.new(db: '14')

#   before(:all) do
#     @account_confirmed = Account.create(
#       :email => 'abc@abc.abc',
#       :crypted_password => ::BCrypt::Password.create('1234567890'),
#       :role => "user",
#       :confirmed => true,
#       :active => false,
#       :port => 234567
#     )
#     @account_not_confirmed = Account.create(
#       :email => 'abc1@abc1.abc1',
#       :crypted_password => ::BCrypt::Password.create('1234567890'),
#       :role => "user",
#       :confirmed => false,
#       :active => false,
#       :port => 2345678
#     )
#   end

#   it "does not validate empty init message" do
#     init_message = {}
#     expect(valid?(init_message)).to eql(false)
#   end

#   it "does not validate init message without email" do
#     init_message = {'password' => '123'}
#     expect(valid?(init_message)).to eql(false)
#   end

#   it "does not validate init message without password" do
#     init_message = {'email' => '1234'}
#     expect(valid?(init_message)).to eql(false)
#   end

#   it "validates init message with email and password" do
#     init_message = {'email' => 'a@a.a', 'password' => '1234'}
#     expect(valid?(init_message)).to eql(true)
#   end

#   it "does not authenticate user if account is nil" do
#     init_message = {'email' => 'a@a.a', 'password' => '1234'}
#     expect(authenticate(init_message)).to eql(false)
#   end

#   it "authenticates user if account is confirmed" do
#     init_message = {'email' => 'abc@abc.abc', 'password' => '1234567890'}
#     expect(authenticate(init_message)).to eql(@account_confirmed)
#   end

#   it "does not authenticate user if account is not confirmed" do
#     init_message = {'email' => 'abc1@abc1.abc1', 'password' => '1234567890'}
#     expect(authenticate(init_message)).to eql(false)
#   end

#   it "does not authenticate user if password is not correct" do
#     init_message = {'email' => 'abc@abc.abc', 'password' => '1234567891'}
#     expect(authenticate(init_message)).to eql(false)
#   end

#   after(:all) do
#     @account_confirmed.destroy
#     @account_not_confirmed.destroy
#   end

# end
