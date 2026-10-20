require 'rack-protection'

module OmniAuth
  class AuthenticityError < StandardError; end

  class AuthenticityTokenProtection < Rack::Protection::AuthenticityToken
    # Used as a validation hook rather than as middleware, so there's no app.
    def initialize(options = {})
      super(nil, options)
    end

    def self.call(env)
      new.call!(env)
    end

    def call!(env)
      return if accepts?(env)

      instrument env
      react env
    end

    alias call call!

  private

    def deny(_env)
      OmniAuth.logger.warn("Attack prevented by #{self.class}")
      raise AuthenticityError.new(options.fetch(:message))
    end

    alias default_reaction deny
  end
end
