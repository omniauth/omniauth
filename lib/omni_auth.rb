require 'rack'
require 'singleton'

module OmniAuth
  class Configuration
    include Singleton
    
    def initialize
      @path_prefix = '/auth'
      @on_failure = Proc.new do |env, message_key|
        new_path = "#{OmniAuth.config.path_prefix}/failure?message=#{message_key}"
        [302, {'Location' => "#{new_path}"}, []]
      end
    end
    
    def on_failure(&block)
      if block_given?
        @on_failure = block
      else
        @on_failure
      end
    end
    
    attr_accessor :path_prefix
  end
  
  def self.config
    Configuration.instance
  end
  
  def self.configure
    yield config
  end
end

require 'omni_auth/strategy'
%w(oauth http_basic linked_in gowalla twitter).each do |s|
  require "omni_auth/strategies/#{s}"
end