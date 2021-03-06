ENV['RACK_ENV'] = 'test'

# require "codeclimate-test-reporter"
# CodeClimate::TestReporter.start

require 'rack/test'
require 'rspec'
require 'pry'
require 'database_cleaner'

DatabaseCleaner[:sequel].strategy = :truncation

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }

def make_crypted(password)
  ::BCrypt::Password.create(password)
end
