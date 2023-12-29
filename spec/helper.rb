if ENV['COVERAGE'] == 'true'
  require 'simplecov'
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
