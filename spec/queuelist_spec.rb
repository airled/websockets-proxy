require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../lib/queuelist.rb', __FILE__

describe 'Queuelist' do

  before(:all) do
    @queuelist = Queuelist.new
  end

  before(:each) do
    Redis.new(db:15).flushdb
  end

  it 'should create proper database number' do
    expect(@queuelist.inspect[-5..-3]).to eql('/15')
  end

  it 'should insert queue into Redis database when set' do
    @queuelist.set('weAreSoldiers')
    expect(Redis.new(db:15).keys).to include('weAreSoldiers')
  end

  it 'should remove queue from Redis database when unset' do
    @queuelist.set('weAreSoldiers')
    @queuelist.unset('weAreSoldiers')
    expect(Redis.new(db:15).get('weAreSoldiers')).to eql(nil)
  end

  it 'should return true if the queue is in the list' do
    Redis.new(db:15).set('RedPill', '')
    expect(@queuelist.has_queue?('RedPill')).to eql(true)
  end

  it 'should return false if the queue is not in the list' do
    expect(@queuelist.has_queue?('HasYou')).to eql(false)
  end

  it 'should clear all the list' do
    Redis.new(db:15).set('FreeYourMind', '')
    expect(@queuelist.has_queue?('FreeYourMind')).to eql(true)
    @queuelist.clear
    expect(Redis.new(db:15).keys.empty?).to eql(true)
  end

  after(:all) do
    Redis.new(db:15).flushdb
  end

end
