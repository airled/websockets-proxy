require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../servers/ws.rb', __FILE__

describe "Websocket server" do

  it "does not validate empty init message" do
    init_message = {}
    expect(valid?(init_message)).to eql(false)
  end

  it "does not validate init message without email" do
    init_message = {'password' => '123'}
    expect(valid?(init_message)).to eql(false)
  end

  it "does not validate init message without password" do
    init_message = {'email' => '1234'}
    expect(valid?(init_message)).to eql(false)
  end

  it "validates init message with email and password" do
    init_message = {'email' => 'a@a.a', 'password' => '1234'}
    expect(valid?(init_message)).to eql(true)
  end

  it "does not authenticate user if account is nil" do
    init_message = {'email' => 'a@a.a', 'password' => '1234'}
    expect(authenticate(init_message)).to eql(false)
  end

  it "does not authenticate user if account is not confirmed" do
    account = Account.create(
      :email => 'abc@abc.abc',
      :crypted_password => ::BCrypt::Password.create('1234567890'),
      :role => "user",
      :confirmed => false,
      :active => false,
      :queue => '111',
      :port => 234567
    )
    init_message = {'email' => 'abc@abc.abc', 'password' => '1234567890'}
    expect(authenticate(init_message)).to eql(false)
    account.destroy
  end

  it "does not authenticate user if password is not correct" do
    account = Account.create(
      :email => 'abc@abc.abc',
      :crypted_password => ::BCrypt::Password.create('1234567890'),
      :role => "user",
      :confirmed => false,
      :active => false,
      :queue => '111',
      :port => 234567
    )
    init_message = {'email' => 'abc@abc.abc', 'password' => '1234567891'}
    expect(authenticate(init_message)).to eql(false)
    account.destroy
  end

  it "authenticates user if account is confirmed" do
    account = Account.create(
      :email => 'abc@abc.abc',
      :crypted_password => ::BCrypt::Password.create('1234567890'),
      :role => "user",
      :confirmed => true,
      :active => false,
      :queue => '111',
      :port => 234567
    )
    init_message = {'email' => 'abc@abc.abc', 'password' => '1234567890'}
    expect(authenticate(init_message)).to eql(account)
    account.destroy
  end

  it "activates account" do
    account = Account.create(
      :email => 'abc@abc.abc',
      :crypted_password => ::BCrypt::Password.create('1234567890'),
      :role => "user",
      :confirmed => true,
      :active => false,
      :queue => '111',
      :port => 234567
    )
    PORTLIST = Redis.new(db: '14')
    activate(account)
    expect(account.active).to eql(true)
    expect(PORTLIST.keys.include?(account.port.to_s)).to eql(true)
    account.destroy
    PORTLIST.flushdb
  end

  it "deactivates account" do
    account = Account.create(
      :email => 'abc@abc.abc',
      :crypted_password => ::BCrypt::Password.create('1234567890'),
      :role => "user",
      :confirmed => true,
      :active => true,
      :queue => '111',
      :port => 234567
    )
    PORTLIST = Redis.new(db: '14')
    PORTLIST.set(account.port, account.queue)
    deactivate(account)
    expect(account.active).to eql(false)
    expect(PORTLIST.keys.include?(account.port.to_s)).to eql(false)
    account.destroy
    PORTLIST.flushdb
  end

end
