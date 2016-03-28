require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../servers/ws.rb', __FILE__

describe "Websocket server" do

  before(:all) do
    @queuelist = Queuelist.new
    @account = Account.create(
      :email => 'ma@il.su',
      :crypted_password => ::BCrypt::Password.create('11111111'),
      :role => "user",
      :port => nil
    )
  end

  it "should not validate empty init message" do
    init_message = {}
    expect(valid?(init_message)).to eql(false)
  end

  it "should not validate init message without email" do
    init_message = {'password' => '11111111', 'profile' => 'profprof'}
    expect(valid?(init_message)).to eql(false)
  end

  it "should not validate init message without password" do
    init_message = {'email' => 'ma@il.su', 'profile' => 'profprof'}
    expect(valid?(init_message)).to eql(false)
  end

  it "should not validate init message without profile" do
    init_message = {'email' => 'ma@il.su', 'password' => '11111111'}
    expect(valid?(init_message)).to eql(false)
  end

  it "should validate init message with email, password and profile" do
    init_message = {'email' => 'a@a.a', 'password' => '1234', 'profile' => 'profprof'}
    expect(valid?(init_message)).to eql(true)
  end

  it "should not authenticate user if account is nil" do
    init_message = {'email' => 'a@a.a', 'password' => '11111111', 'profile' => 'profprof'}
    expect(authenticate(init_message)).to eql(false)
  end

  it "should not authenticate user if password is not correct" do
    init_message = {'email' => 'ma@il.su', 'password' => '22222222', 'profile' => 'profprof'}
    expect(authenticate(init_message)).to eql(false)
  end

  it "should not authenticate user if it has no port" do
    init_message = {'email' => 'ma@il.su', 'password' => '11111111', 'profile' => 'profprof'}
    expect(authenticate(init_message)).to eql(false)
  end

  it "should authenticate user if all parameters are right" do
    @account.update(port: 1111)
    init_message = {'email' => 'ma@il.su', 'password' => '11111111', 'profile' => 'profprof'}
    expect(authenticate(init_message)).to be_truthy
    expect(authenticate(init_message)).to be_instance_of(Account)
  end

  after(:all) do
    @account.destroy
  end

end
