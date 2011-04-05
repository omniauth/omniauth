require 'rubygems'
require 'bundler'
Bundler.setup
require 'rspec'
require 'rspec/autorun'
require 'webmock/rspec'
require 'rack/test'
require 'omniauth/core'
require 'omniauth/test'
require 'omniauth/openid'

RSpec.configure do |config|
  config.include WebMock::API
  config.include Rack::Test::Methods
  config.extend  OmniAuth::Test::StrategyMacros, :type => :strategy
end

WebMock.disable_net_connect!
