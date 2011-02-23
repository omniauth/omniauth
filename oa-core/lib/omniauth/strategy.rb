require 'omniauth/core'

module OmniAuth
  class NoSessionError < StandardError; end
  module Strategy
    def self.included(base)
      OmniAuth.strategies << base
      base.class_eval do
        attr_reader :app, :name, :env, :options, :response
      end
    end

    def initialize(app, name, *args, &block)
      @app = app
      @name = name.to_sym
      @options = args.last.is_a?(Hash) ? args.pop : {}

      yield self if block_given?
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      raise OmniAuth::NoSessionError.new("You must provide a session to use OmniAuth.") unless env['rack.session']
      @env = env
      return mock_call!(env) if OmniAuth.config.test_mode

      if current_path == request_path && OmniAuth.config.allowed_request_methods.include?(request.request_method.downcase.to_sym)
        if response = call_through_to_app
          response
        else
          env['rack.session']['omniauth.origin'] = env['HTTP_REFERER']
          request_phase
        end
      elsif current_path == callback_path
        env['omniauth.origin'] = session.delete('omniauth.origin')
        env['omniauth.origin'] = nil if env['omniauth.origin'] == ''
        if response = call_through_to_app
          response
        else
          callback_phase
        end
      else
        if respond_to?(:other_phase)
          other_phase
        else
          @app.call(env)
        end
      end
    end

    def mock_call!(env)
      if current_path == request_path
        if response = call_through_to_app
          response
        else
          env['rack.session']['omniauth.origin'] = env['HTTP_REFERER']
          redirect(callback_path)
        end
      elsif current_path == callback_path
        @env['omniauth.auth'] = OmniAuth.mock_auth_for(name.to_sym)
        call_app!
      else
        call_app!
      end
    end

    def request_phase
      raise NotImplementedError
    end

    def callback_phase
      @env['omniauth.auth'] = auth_hash
      call_app!
    end

    def path_prefix
      options[:path_prefix] || OmniAuth.config.path_prefix
    end

    def request_path
      options[:request_path] || "#{path_prefix}/#{name}"
    end

    def callback_path
      options[:callback_path] || "#{path_prefix}/#{name}/callback"
    end

    def current_path
      request.path.sub(/\/$/,'')
    end

    def query_string
      request.query_string.empty? ? "" : "?#{request.query_string}"
    end

    def call_through_to_app
      status, headers, body = *call_app!(request_path)
      @response = Rack::Response.new(body, status, headers)

      status == 404 ? nil : @response.finish
    end

    def call_app!(path_info = nil)
      @env['omniauth.strategy'] = self
      last_path_info = @env['PATH_INFO']
      @env['PATH_INFO'] = path_info if path_info
      result = @app.call(@env)
      @env['PATH_INFO'] = last_path_info
      result
    end

    def auth_hash
      {
        'provider' => name.to_s,
        'uid' => nil
      }
    end

    def full_host
      case OmniAuth.config.full_host
        when String
          OmniAuth.config.full_host
        when Proc
          OmniAuth.config.full_host.call(env)
        else
          uri = URI.parse(request.url)
          uri.path = ''
          uri.query = nil
          uri.to_s
      end
    end

    def callback_url
      full_host + callback_path + query_string
    end

    def session
      @env['rack.session']
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def redirect(uri)
      r = Rack::Response.new

      if options[:iframe]
        r.write("<script type='text/javascript' charset='utf-8'>top.location.href = '#{uri}';</script>")
      else
        r.write("Redirecting to #{uri}...")
        r.redirect(uri)
      end

      r.finish
    end

    def user_info; {} end

    def fail!(message_key, exception = nil)
      self.env['omniauth.error'] = exception
      self.env['omniauth.error.type'] = message_key.to_sym
      self.env['omniauth.error.strategy'] = self

      OmniAuth.config.on_failure.call(self.env)
    end
  end
end
