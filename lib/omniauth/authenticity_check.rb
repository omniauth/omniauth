require 'rack-protection'

module OmniAuth
  class AuthenticityCheck < Rack::Protection::AuthenticityToken
    def initialize(options = {})
      @options = default_options.merge(options)
    end

    def call(env)
      return if accepts?(env)

      instrument env
      react env
    end

    def deny(env)
      warn env, "attack prevented by #{self.class}"
      raise OmniAuth::InvalidSessionError.new options[:message]
    end

    default_reaction :deny
  end
end
