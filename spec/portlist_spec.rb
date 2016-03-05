require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../lib/portlist.rb', __FILE__

describe 'Portlist' do

  before(:all) do
    @portlist = Portlist.new
  end

  it 'should create proper database number' do
    expect(@portlist.inspect[-5..-3]).to eql('/15')
  end

  it 'should add port to the list when binding to a queue and find it' do
    @portlist.bind('10000', 'testtest')
    expect(@portlist.include?('10000')).to eql(true)
  end

  it 'should remove port from the list when unbinding' do
    @portlist.unbind('10000')
    expect(@portlist.include?('10000')).to eql(false)
  end

  it 'should clear all the list' do
    @portlist.bind('10000', 'testtest')
    expect(@portlist.clear).to eql('OK')
  end

  after(:all) do
    @portlist.clear
  end

end
