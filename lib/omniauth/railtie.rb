require 'omniauth/request_forgery_protection'

module OmniAuth
  class Railtie < Rails::Railtie
    initializer 'omniauth' do
      OmniAuth.config.logger = Rails.logger

      # Protect request phase against CSRF.
      OmniAuth.config.allowed_request_methods = [:post]
      OmniAuth.config.before_request_phase do |env|
        RequestForgeryProtection.new(env).call
      end
    end
  end
end
