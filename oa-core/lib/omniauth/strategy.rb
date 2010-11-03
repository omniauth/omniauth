require 'omniauth/core'

module OmniAuth
  
  module Strategy
    
    def self.included(base)
      base.class_eval do
        attr_reader :app, :name, :env, :options, :response
      end
    end
     
    def initialize(app, name, *args)
      @app = app
      @name = name.to_sym
      @options = args.last.is_a?(Hash) ? args.pop : {}
    end
    
    def call(env)
      dup.call!(env)
    end

    def call!(env)
      @env = env
      if request.path == request_path
        status, headers, body = *call_app!
        @response = Rack::Response.new(body, status, headers)
        request_phase
      elsif request.path == callback_path
        callback_phase
      else
        if respond_to?(:other_phase)
          other_phase
        else
          call_app!
        end
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
    
    def call_app!
      # TODO: Remove this when we get to 0.2.0
      @env['rack.auth'] = env['omniauth.auth'] if env.key?('omniauth.auth')
      @env['rack.auth.error'] = env['omniauth.error'] if env.key?('omniauth.error')
      
      @app.call(@env)
    end
    
    def auth_hash
      {
        'provider' => name.to_s,
        'uid' => nil
      }
    end
    
    def full_host
      uri = URI.parse(request.url)
      uri.path = ''
      uri.query = nil
      uri.to_s
    end
    
    def callback_url
      full_host + "#{OmniAuth.config.path_prefix}/#{name}/callback"
    end
    
    def session
      @env['rack.session']
    end

    def request
      @request ||= Rack::Request.new(@env)
    end
    
    def redirect(uri)
      r = Rack::Response.new("Redirecting to #{uri}...")
      r.redirect(uri)
      r.finish
    end
    
    def user_info; {} end
    
    def fail!(message_key, exception = nil)
      self.env['omniauth.error'] = exception
      OmniAuth.config.on_failure.call(self.env, message_key.to_sym)
    end
  end
end