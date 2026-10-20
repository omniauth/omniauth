module OmniAuth
  class Builder < ::Rack::Builder
    def on_failure(&block)
      OmniAuth.config.on_failure = block
    end

    def before_options_phase(&block)
      OmniAuth.config.before_options_phase = block
    end

    def before_request_phase(&block)
      OmniAuth.config.before_request_phase = block
    end

    def after_request_phase(&block)
      OmniAuth.config.after_request_phase = block
    end

    def before_callback_phase(&block)
      OmniAuth.config.before_callback_phase = block
    end

    def configure(&block)
      OmniAuth.configure(&block)
    end

    def options(options = false)
      case options
      when false then @options ||= {}
      else @options = options
      end
    end

    def provider(klass, *args, **opts, &block)
      if klass.instance_of?(Class)
        middleware = klass
      else
        begin
          middleware = Strategies.const_get(Utils.camelize(klass), false)
        rescue NameError
          raise(LoadError.new("Could not find matching strategy for #{klass.inspect}. You may need to install an additional gem (such as omniauth-#{klass})."))
        end
      end

      use middleware, *args, **options.merge(opts), &block
    end

    # Rack::Builder#call rebuilds the whole middleware stack on every
    # request. Build it on the first request and reuse it after that.
    def call(env)
      (@built_app ||= to_app).call(env)
    end
  end
end
