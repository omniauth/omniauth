require 'rack'
require 'singleton'
require 'logger'

module OmniAuth
  class Error < StandardError; end

  module Strategies
    autoload :Developer, 'omniauth/strategies/developer'
  end

  autoload :Builder,  'omniauth/builder'
  autoload :Configuration, 'omniauth/configuration'
  autoload :Strategy, 'omniauth/strategy'
  autoload :Test,     'omniauth/test'
  autoload :Form,     'omniauth/form'
  autoload :AuthHash, 'omniauth/auth_hash'
  autoload :FailureEndpoint, 'omniauth/failure_endpoint'
  autoload :Utils,    'omniauth/utils'

  def self.strategies
    @strategies ||= []
  end

  def self.config
    Configuration.instance
  end

  def self.configure
    yield config
  end

  def self.logger
    config.logger
  end

  def self.mock_auth_for(provider)
    config.mock_auth[provider.to_sym] || config.mock_auth[:default]
  end
end
