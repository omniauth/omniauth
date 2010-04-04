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
  
  def self.build(stack, &block)
    OmniAuth::Builder.new(stack, &block)
  end
  
  def self.config
    Configuration.instance
  end
  
  def self.configure
    yield config
  end
  
  module Utils
    extend self
    
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
    
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      return "OAuth" if lower_case_and_underscored_word.to_s == 'oauth'
      return "OpenID" if lower_case_and_underscored_word.to_s == 'open_id'
      
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end
  end
end

require 'omni_auth/strategy'
%w(oauth http_basic linked_in gowalla twitter open_id).each do |s|
  require "omni_auth/strategies/#{s}"
end
require 'omni_auth/builder'