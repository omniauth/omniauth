require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'simplecov'
SimpleCov.start
require 'rack/test'
require 'omniauth/identity'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

