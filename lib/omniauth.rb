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
  autoload :AuthenticityTokenProtection, 'omniauth/authenticity_token_protection'

  def self.strategies
    @strategies ||= []
  end

  class Configuration
    include Singleton

    def self.default_logger
      logger = Logger.new($stdout)
      logger.progname = 'omniauth'
      logger
    end

    def self.defaults # rubocop:disable Metrics/MethodLength
      @defaults ||= {
        :camelizations => {},
        :path_prefix => '/auth',
        :on_failure => FailureEndpoint,
        :failure_raise_out_environments => ['development'],
        :request_validation_phase => AuthenticityTokenProtection,
        :before_request_phase   => nil,
        :after_request_phase    => nil,
        :before_callback_phase  => nil,
        :before_options_phase   => nil,
        :form_css => Form::DEFAULT_CSS,
        :test_mode => false,
        :logger => default_logger,
        :allowed_request_methods => %i[post],
        :mock_auth => {:default => AuthHash.new('provider' => 'default', 'uid' => '1234', 'info' => {'name' => 'Example User'})},
        :silence_get_warning => false,
        :allowed_hosts => nil
      }
    end

    def initialize
      self.class.defaults.each_pair { |k, v| public_send("#{k}=", v) }
    end

    def on_failure(&block)
      if block_given?
        @on_failure = block
      else
        @on_failure
      end
    end

    def before_callback_phase(&block)
      if block_given?
        @before_callback_phase = block
      else
        @before_callback_phase
      end
    end

    def before_options_phase(&block)
      if block_given?
        @before_options_phase = block
      else
        @before_options_phase
      end
    end

    def request_validation_phase(&block)
      if block_given?
        @request_validation_phase = block
      else
        @request_validation_phase
      end
    end

    def before_request_phase(&block)
      if block_given?
        @before_request_phase = block
      else
        @before_request_phase
      end
    end

    def after_request_phase(&block)
      if block_given?
        @after_request_phase = block
      else
        @after_request_phase
      end
    end

    def add_mock(provider, original = {})
      # Create key-stringified new hash from given auth hash
      mock = {} #: Hash[String, untyped]
      original.each_pair do |key, val|
        mock[key.to_s] = if val.is_a? Hash
                           val.transform_keys(&:to_s)
                         else
                           val
                         end
      end

      # Merge with the default mock and ensure provider is correct.
      default = mock_auth.fetch(:default) #: AuthHash
      mock = default.merge(mock)
      mock['provider'] = provider.to_s

      # Add it to the mocks.
      mock_auth[provider.to_sym] = mock
    end

    # This is a convenience method to be used by strategy authors
    # so that they can add special cases to the camelization utility
    # method that allows OmniAuth::Builder to work.
    #
    # @param name [String] The underscored name, e.g. `oauth`
    # @param camelized [String] The properly camelized name, e.g. 'OAuth'
    def add_camelization(name, camelized)
      camelizations[name.to_s] = camelized.to_s
    end

    attr_writer :on_failure, :before_callback_phase, :before_options_phase, :before_request_phase, :after_request_phase, :request_validation_phase
    attr_accessor :failure_raise_out_environments, :path_prefix, :allowed_request_methods, :form_css,
                  :test_mode, :mock_auth, :full_host, :camelizations, :logger, :silence_get_warning,
                  :allowed_hosts
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

      other_hash.each_pair do |key, value|
        current = hash[key]
        target[key] = current.is_a?(Hash) && value.is_a?(Hash) ? deep_merge(current, value) : value
      end

      target
    end

    def camelize(word, first_letter_in_uppercase = true)
      camelized = OmniAuth.config.camelizations[word.to_s]
      return camelized if camelized

      if first_letter_in_uppercase
        namespaced = word.to_s.gsub(%r{/(.?)}) do
          char = Regexp.last_match(1) #: String
          "::#{char.upcase}"
        end
        namespaced.gsub(/(\A|_)(.)/) do
          char = Regexp.last_match(2) #: String
          char.upcase
        end
      else
        camelize(word).tap { |w| w[0] = w[0].to_s.downcase }
      end
    end
  end
end
