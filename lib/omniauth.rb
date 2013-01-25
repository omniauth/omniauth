require 'rack'
require 'singleton'
require 'logger'

module OmniAuth
  class Error < StandardError; end

  module Strategies
    autoload :Developer, 'omniauth/strategies/developer'
  end

  autoload :Builder,  'omniauth/builder'
  autoload :Strategy, 'omniauth/strategy'
  autoload :Test,     'omniauth/test'
  autoload :Form,     'omniauth/form'
  autoload :AuthHash, 'omniauth/auth_hash'
  autoload :FailureEndpoint, 'omniauth/failure_endpoint'

  def self.strategies
    @@strategies ||= []
  end

  class Configuration
    include Singleton

    def self.default_logger
      logger = Logger.new(STDOUT)
      logger.progname = "omniauth"
      logger
    end

    @@defaults = {
      :camelizations => {},
      :path_prefix => '/auth',
      :on_failure => OmniAuth::FailureEndpoint,
      :form_css => Form::DEFAULT_CSS,
      :test_mode => false,
      :logger => default_logger,
      :allowed_request_methods => [:get, :post],
      :mock_auth => {
        :default => AuthHash.new(
          'provider' => 'default',
          'uid' => '1234',
          'info' => {
            'name' => 'Bob Example'
          }
        )
      }
    }

    def self.defaults
      @@defaults
    end

    def initialize
      @@defaults.each_pair{|k,v| self.send("#{k}=",v)}
    end

    def on_failure(&block)
      if block_given?
        @on_failure = block
      else
        @on_failure
      end
    end

    def add_mock(provider, mock={})
      # Stringify keys recursively one level.
      mock.keys.each do |key|
        mock[key.to_s] = mock.delete(key)
      end
      mock.each_pair do |key, val|
        if val.is_a? Hash
          val.keys.each do |subkey|
            val[subkey.to_s] = val.delete(subkey)
          end
        end
      end

      # Merge with the default mock and ensure provider is correct.
      mock = self.mock_auth[:default].dup.merge(mock)
      mock["provider"] = provider.to_s

      # Add it to the mocks.
      self.mock_auth[provider.to_sym] = mock
    end

    # This is a convenience method to be used by strategy authors
    # so that they can add special cases to the camelization utility
    # method that allows OmniAuth::Builder to work.
    #
    # @param name [String] The underscored name, e.g. `oauth`
    # @param camelized [String] The properly camelized name, e.g. 'OAuth'
    def add_camelization(name, camelized)
      self.camelizations[name.to_s] = camelized.to_s
    end

    attr_writer :on_failure
    attr_accessor :path_prefix, :allowed_request_methods, :form_css, :test_mode, :mock_auth, :full_host, :camelizations, :logger
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

  module Utils
    module_function

    def form_css
      "<style type='text/css'>#{OmniAuth.config.form_css}</style>"
    end

    def deep_merge(hash, other_hash)
      target = hash.dup

      other_hash.keys.each do |key|
        if other_hash[key].is_a? ::Hash and hash[key].is_a? ::Hash
          target[key] = deep_merge(target[key],other_hash[key])
          next
        end

        target[key] = other_hash[key]
      end

      target
    end

    def camelize(word, first_letter_in_uppercase = true)
      return OmniAuth.config.camelizations[word.to_s] if OmniAuth.config.camelizations[word.to_s]

      if first_letter_in_uppercase
        word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        word.first + camelize(word)[1..-1]
      end
    end
  end
end
