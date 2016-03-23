ENV['RACK_ENV'] = 'test'

# require "codeclimate-test-reporter"
# CodeClimate::TestReporter.start

require 'rack/test'
require 'rspec'
require 'pry'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }
