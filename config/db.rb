require 'sequel'
require 'mysql2'

ENV['RACK_ENV'] ||= 'development'

def get_db
  case ENV['RACK_ENV']
  when 'development'
    'ws_development'
  when 'production'
    'ws_production'
  when 'test'
    'ws_test'
  end
end

DB = Sequel.connect(
  adapter: 'mysql2',
  host: 'localhost',
  user: 'root',
  database: get_db
)
