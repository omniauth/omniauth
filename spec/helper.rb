require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage(93.05)
end

require 'rspec'
require 'rack/test'
require 'omniauth'
require 'omniauth/test'

OmniAuth.config.logger = Logger.new('/dev/null')

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
    self.call!(env)
  end

  def initialize(*args, &block)
    super
    @fail = nil
  end

  def request_phase
    @fail = fail!(options[:failure]) if options[:failure]
    @last_env = env
    return @fail if @fail
    fail('Request Phase')
  end

  def callback_phase
    @fail = fail!(options[:failure]) if options[:failure]
    @last_env = env
    return @fail if @fail
    fail('Callback Phase')
  end
end
