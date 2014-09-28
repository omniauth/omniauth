require 'rack'
require 'singleton'
require 'logger'
require 'ostruct'

module OmniAuth
  class Error < StandardError; end

  module Strategies
    autoload :Developer, 'omniauth/strategies/developer'
  end

  class OmniStruct < ::OpenStruct

    def to_hash(options = {})
      self.to_h.each_with_object({}) do |(key, value), object|
        puts value.method(:to_hash).source_location if value.is_a?(OmniStruct)
        value = value.to_hash(options) if value.is_a?(OmniStruct)
        key   = if options[:stringify_keys]
                   key.to_s
                 elsif options[:symbolize_keys]
                   key.to_sym
                 else
                   key.to_s
                 end
        object[key] = value
      end
    end

    # internal ostruct implementaiton needed for on_write to work
    def initialize(*args)
      new_args = {}
      args.each do |hash|
        hash.each do |key, value|
          new_args[key] = on_write(key, value)
        end
      end
      super new_args
    end

    def on_write(key, value)
      value.is_a?(::Hash) ? self.class.new(value) : value
    end

    # internal ostruct implementaiton needed for on_write to work
    def new_ostruct_member(name)
      name = name.to_sym
      unless respond_to?(name)
        define_singleton_method(name) { @table[name] }
        define_singleton_method("#{name}=") { |value| modifiable[name] = on_write(name, value) }
      end
      name
    end

    EQUAL_END = /=$/

    # internal ostruct implementaiton needed for on_write to work
    def method_missing(method_name, *args)
      if method_name.to_s.match(EQUAL_END)
        args.map! {|arg| on_write(method_name.to_s.gsub(EQUAL_END, '').to_sym, arg) }
      end
      super method_name, *args
    end

    def merge!(hash)
      hash.each do |key, value|
        self[key] = value
      end
    end

    def deep_merge!(hash)
      hash.each do |key, value|
        if value.is_a?(::Hash)
          merge_hash = self[key].respond_to?(:to_h) ? self[key].to_h : {}
          value      = on_write(key, merge_hash.merge(value))
        end
        self[key] = value
      end
      self
    end

    def merge(hash)
      self.dup.deep_merge!(hash)
    end
  end

  autoload :Builder,  'omniauth/builder'
  autoload :Strategy, 'omniauth/strategy'
  autoload :Test,     'omniauth/test'
  autoload :Form,     'omniauth/form'
  autoload :AuthHash, 'omniauth/auth_hash'
  autoload :FailureEndpoint, 'omniauth/failure_endpoint'

  def self.strategies
    @strategies ||= []
  end

  class Configuration
    include Singleton

    def self.default_logger
      logger = Logger.new(STDOUT)
      logger.progname = 'omniauth'
      logger
    end

    def self.defaults
      @defaults ||= {
        :camelizations => {},
        :path_prefix => '/auth',
        :on_failure => OmniAuth::FailureEndpoint,
        :failure_raise_out_environments => ['development'],
        :before_request_phase   => nil,
        :before_callback_phase  => nil,
        :before_options_phase   => nil,
        :form_css => Form::DEFAULT_CSS,
        :test_mode => false,
        :logger => default_logger,
        :allowed_request_methods => [:get, :post],
        :mock_auth => {:default => AuthHash.new('provider' => 'default', 'uid' => '1234', 'info' => {'name' => 'Example User'})},
      }
    end

    def initialize
      self.class.defaults.each_pair { |k, v| send("#{k}=", v) }
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

    def before_request_phase(&block)
      if block_given?
        @before_request_phase = block
      else
        @before_request_phase
      end
    end

    def add_mock(provider, mock = {})
      # Stringify keys recursively one level.
      mock.keys.each do |key|
        mock[key.to_s] = mock.delete(key)
      end
      mock.each_pair do |_key, val|
        if val.is_a? Hash
          val.keys.each do |subkey|
            val[subkey.to_s] = val.delete(subkey)
          end
        else
          next
        end
      end

      # Merge with the default mock and ensure provider is correct.
      mock = mock_auth[:default].dup.merge(mock)
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

    attr_writer :on_failure, :before_callback_phase, :before_options_phase, :before_request_phase
    attr_accessor :failure_raise_out_environments, :path_prefix, :allowed_request_methods, :form_css, :test_mode, :mock_auth, :full_host, :camelizations, :logger
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
        if other_hash[key].is_a?(::Hash) && hash[key].is_a?(::Hash)
          target[key] = deep_merge(target[key], other_hash[key])
          next
        end

        target[key] = other_hash[key]
      end

      target
    end

    def camelize(word, first_letter_in_uppercase = true)
      return OmniAuth.config.camelizations[word.to_s] if OmniAuth.config.camelizations[word.to_s]

      if first_letter_in_uppercase
        word.to_s.gsub(/\/(.?)/) { '::' + Regexp.last_match[1].upcase }.gsub(/(^|_)(.)/) { Regexp.last_match[2].upcase }
      else
        word.first + camelize(word)[1..-1]
      end
    end
  end
end
