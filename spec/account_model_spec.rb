require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../account_model.rb', __FILE__

describe "Account model" do

  before(:all) do
    @accout_confirmed_and_active = Account.create(
      :email => 'abc@abc.abc',
      :crypted_password => ::BCrypt::Password.create('1234567890'),
      :role => "user",
      :confirmed => true,
      :active => true,
      :queue => '111',
      :port => 234567
    )
    @account_not_confirmed_and_not_active = Account.create(
      :email => 'abc1@abc1.abc1',
      :crypted_password => ::BCrypt::Password.create('1234567890'),
      :role => "user",
      :confirmed => false,
      :active => false,
      :queue => '1111',
      :port => 234568
    )
  end

  it "should return true if account is confirmed" do
    expect(@accout_confirmed_and_active.confirmed?).to eql(true)
  end

  it "should return false if account is not confirmed" do
    expect(@account_not_confirmed_and_not_active.confirmed?).to eql(false)
  end

  it "should check if passwords are equal" do
    expect(@accout_confirmed_and_active.has_password?('1234567890')).to eql(true)
    expect(@accout_confirmed_and_active.has_password?('12345678901')).to eql(false)
  end

  it "should activate not active account" do
    @account_not_confirmed_and_not_active.activate
    expect(@account_not_confirmed_and_not_active.active).to eql(true)
  end

  it "should deactivate active account" do
    @accout_confirmed_and_active.deactivate
    expect(@accout_confirmed_and_active.active).to eql(false)
  end

  after(:all) do
    @accout_confirmed_and_active.destroy
    @account_not_confirmed_and_not_active.destroy
  end

end

