require 'singleton'

module Omokawa
  class Configuration
    include Singleton

    def self.defaults
      @defaults ||= {
        :hoge => 'hoge1',
        :fuga => 'fuga1',
      }
    end

    def initialize
      self.class.defaults.each_pair { |k, v| send("#{k}=", v)}
    end

    attr_accessor(*defaults.keys)
  end

  def self.config
    Configuration.instance
  end
end

p Omokawa.config.hoge
p Omokawa.config.fuga
