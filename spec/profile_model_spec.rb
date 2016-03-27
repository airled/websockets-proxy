require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../models/profile_model.rb', __FILE__

describe "Profile model" do

  before(:all) do
    @profile = Profile.create(
      account_id: 10,
      name: 'testname',
      queue: 'testqueue',
      active: false
    )
  end

  it 'should activate profile' do
    @profile.activate
    expect(@profile.active).to eql(true)
  end

  it 'should deactivate active profile' do
    @profile.deactivate
    expect(@profile.active).to eql(false)
  end

  it 'should return true if profile is active' do
    @profile.activate
    expect(@profile.active?).to eql(true)
  end

  it 'should return false if profile is not active' do
    @profile.deactivate
    expect(@profile.active?).to eql(false)
  end

  after(:all) do
    @profile.destroy
  end

end
