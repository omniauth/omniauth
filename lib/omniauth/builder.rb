require 'omniauth'

module OmniAuth
  class Builder < ::Rack::Builder
    def initialize(app, &block)
      if rack14?
        super
      else
        @app = app
        super(&block)
        @ins << @app
      end
    end

    def rack14?
      Rack.release.split('.')[1].to_i >= 4
    end

    def on_failure(&block)
      OmniAuth.config.on_failure = block
    end

    def configure(&block)
      OmniAuth.configure(&block)
    end

    def options(options = false)
      return @options || {} if options == false
      @options = options
    end

    def provider(klass, *args, &block)
      if klass.is_a?(Class)
        middleware = klass
      else
        begin
          middleware = OmniAuth::Strategies.const_get("#{OmniAuth::Utils.camelize(klass.to_s)}")
        rescue NameError
          raise LoadError, "Could not find matching strategy for #{klass.inspect}. You may need to install an additional gem (such as omniauth-#{klass})."
        end
      end

      args.last.is_a?(Hash) ? args.push(options.merge(args.pop)) : args.push(options)
      use middleware, *args, &block
    end

    def call(env)
      to_app.call(env)
    end
  end
end
