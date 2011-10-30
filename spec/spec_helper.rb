unless ENV['TRAVIS']
  require 'simplecov'
  SimpleCov.start
end

require 'rspec'
require 'rack/test'
require 'omniauth'
require 'omniauth/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.extend  OmniAuth::Test::StrategyMacros, :type => :strategy
end

