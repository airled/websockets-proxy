require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../models/account_model.rb', __FILE__

describe "Account model" do

  before(:all) do
    @account = Account.create(
      :email => 'zxc@zxc.zxc',
      :crypted_password => ::BCrypt::Password.create('qwertyui'),
      :role => "user",
      :port => 234567
    )
    @profile = @account.add_profile(name: 'nekonekonyanya', queue: 'nyanqueue', active: false)
  end

  it "should return true if the passwords are equal" do
    expect(@account.has_password?('qwertyui')).to eql(true)
  end

  it "should return false if the passwords are not equal" do
    expect(@account.has_password?('12345678901')).to eql(false)
  end

  it "should return true if the account has the profile" do
    expect(@account.has_profile?('nekonekonyanya')).to eql(true)
  end

  it "should return false if the account hasn't the profile" do
    expect(@account.has_profile?('imnotexist')).to eql(false)
  end

  after(:all) do
    @account.destroy
    @profile.destroy
  end

end

