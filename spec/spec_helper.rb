unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'rspec'
require 'rack/test'
require 'omniauth'
require 'omniauth/test'

OmniAuth.config.logger = Logger.new("/dev/null")

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.extend  OmniAuth::Test::StrategyMacros, :type => :strategy
end

class ExampleStrategy
  include OmniAuth::Strategy
  option :name, 'test'
  def call(env); self.call!(env) end
  attr_reader :last_env
  def request_phase
    @fail = fail!(options[:failure]) if options[:failure]
    @last_env = env
    return @fail if @fail
    raise "Request Phase"
  end
  def callback_phase
    @fail = fail!(options[:failure]) if options[:failure]
    @last_env = env
    return @fail if @fail
    raise "Callback Phase"
  end
end
