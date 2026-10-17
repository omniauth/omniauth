# Coverage is measured on CRuby only. SimpleCov 1.x needs Ruby 3.2+, and
# JRuby and TruffleRuby count lines differently.
if RUBY_ENGINE == 'ruby' && Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.2')
  require 'simplecov'
  require 'simplecov-lcov'

  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]

  SimpleCov.start 'strict'
end

require 'rspec'
require 'rack/test'
require 'rack/freeze'
require 'omniauth'
require 'omniauth/test'

OmniAuth.config.logger = Logger.new('/dev/null')
OmniAuth.config.request_validation_phase = nil

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.extend OmniAuth::Test::StrategyMacros, :type => :strategy
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class ExampleStrategy
  include OmniAuth::Strategy
  attr_reader :last_env
  option :name, 'test'

  def call(env)
    options[:dup] ? super : call!(env)
  end

  def initialize(*args, &block)
    super
    @fail = nil
  end

  def request_phase
    options[:mutate_on_request].call(options) if options[:mutate_on_request]
    @fail = fail!(options[:failure], options[:failure_exception]) if options[:failure]
    @last_env = env
    return @fail if @fail

    raise('Request Phase')
  end

  def callback_phase
    options[:mutate_on_callback].call(options) if options[:mutate_on_callback]
    @fail = fail!(options[:failure], options[:failure_exception]) if options[:failure]
    @last_env = env
    return @fail if @fail

    raise('Callback Phase')
  end
end
