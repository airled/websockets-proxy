require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../config/db.rb', __FILE__

describe 'Database' do

  it 'should be ws_test if environment is "test"' do
    expect(get_db).to eq('ws_test')
  end

  it 'should be ws_development if environment is "development"' do
    ENV['RACK_ENV'] = 'development'
    expect(get_db).to eq('ws_development')
  end

  it 'should be ws_production if environment is "production"' do
    ENV['RACK_ENV'] = 'production'
    expect(get_db).to eq('ws_production')
  end

end
