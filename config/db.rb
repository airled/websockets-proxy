require 'sequel'
require 'mysql2'

ENV['RACK_ENV'] ||= 'development'

database = 
  case ENV['RACK_ENV']
  when 'development'
    'ws_development'
  when 'production'
    'ws_production'
  end

DB = Sequel.connect(
  adapter: 'mysql2',
  host: 'localhost',
  user: 'root',
  database: database
)
