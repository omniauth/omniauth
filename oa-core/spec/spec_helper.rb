require 'rubygems'
require 'bundler'
Bundler.setup
require 'spec'
require 'spec/autorun'
require 'rack/test'
require 'omniauth/core'
require 'omniauth/test'

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
  config.extend  OmniAuth::Test::StrategyMacros, :type => :strategy
end

WebMock.disable_net_connect!
