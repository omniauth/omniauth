require 'rubygems'
require 'bundler'
Bundler.setup
require 'rspec'
require 'rspec/autorun'
require 'webmock/rspec'
require 'rack/test'
require 'omniauth/core'
require 'omniauth/test'
require 'omniauth/cookie'

RSpec.configure do |config|
  config.include WebMock
  config.include Rack::Test::Methods
  config.extend  OmniAuth::Test::StrategyMacros, :type => :strategy
end

def strategy_class
  meta = self.class.metadata
  while meta.key?(:example_group)
    meta = meta[:example_group]
  end
  meta[:describes]
end

def app
  lambda{|env| [200, {}, ['Hello']]}
end

WebMock.disable_net_connect!
