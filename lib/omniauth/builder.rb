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

    def before_callback_phase(&block)
      OmniAuth.config.before_callback_phase = block
    end

    def configure(&block)
      OmniAuth.configure(&block)
    end

    def options(options = false)
      return @options ||= {} if options == false

      @options = options
    end

    def provider(klass, *args, &block) # rubocop:disable Metrics/MethodLength
      if klass.is_a?(Class)
        middleware = klass
      else
        begin
          middleware = OmniAuth::Strategies.const_get(OmniAuth::Utils.camelize(klass.to_s).to_s)
        rescue NameError
          raise(LoadError.new("Could not find matching strategy for #{klass.inspect}. You may need to install an additional gem (such as omniauth-#{klass})."))
        end
      end

      args.last.is_a?(Hash) ? args.push(options.merge(args.pop)) : args.push(options)
      allowed_paths = args.last.is_a?(Hash) ? args.last.fetch(:allowed_paths, []) : []
      allowed_paths = [allowed_paths] if allowed_paths.is_a?(String)

      if allowed_paths.any?
        allowed_paths.each do |path|
          map(path) do
            use middleware, *args, &block
          end
        end
      else
        use middleware, *args, &block
      end
    end

    def call(env)
      to_app.call(env)
    end
  end
end
