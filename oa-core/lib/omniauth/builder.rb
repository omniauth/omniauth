require 'omniauth/core'

module OmniAuth
  class Builder < ::Rack::Builder
    def initialize(app, &block)
      @app = app
      super(&block)
    end

    def on_failure(&block)
      OmniAuth.config.on_failure = block
    end

    def configure(&block)
      OmniAuth.configure(&block)
    end

    # @param [OmniAuth::Strategy] klass The strategy to use for this provider.
    # @param args Additional arguments that will be passed through to the strategy. The final argument can be an options hash.
    # @option args [String] :path_prefix The base URL to use for all authentication requests. Defaults to OmniAuth::Configuration#path_prefix.
    # @option args [String] :request_path The URL to use for this provider's authentication requests. Defaults to the path prefix appended by the name of the provider.
    # @option args [String] :callback_suffix ('callback') The trailing URL component to use for this provider's callback.
    # @option args [String] :callback_path The full URL to use for this provider's callback. Defaults to the provider's request path appended by the callback suffix.
    # @option args :setup
    # @option args [String] :setup_path
    # @option args [Boolean] :iframe
    def provider(klass, *args, &block)
      if klass.is_a?(Class)
        middleware = klass
      else
        middleware = OmniAuth::Strategies.const_get("#{OmniAuth::Utils.camelize(klass.to_s)}")
      end

      use middleware, *args, &block
    end

    def call(env)
      @ins << @app unless @ins.include?(@app)
      to_app.call(env)
    end
  end
end
