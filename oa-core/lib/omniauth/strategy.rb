module OmniAuth
  module Strategy
    def self.included(base)
      base.class_eval do
        attr_reader :app, :name, :env
      end
    end
     
    def initialize(app, name, *args)
      @app = app
      @name = name.to_sym
    end
    
    def call(env)
      dup.call!(env)
    end

    def call!(env)
      @env = env
      if request.path == "#{OmniAuth.config.path_prefix}/#{name}"
        request_phase
      elsif request.path == "#{OmniAuth.config.path_prefix}/#{name}/callback"
        callback_phase
      else
        if respond_to?(:other_phase)
          other_phase
        else
          @app.call(env)
        end
      end
    end
    
    def request_phase
      raise NotImplementedError
    end
    
    def callback_phase
      request['auth'] = auth_hash
      @app.call(env)
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
    
    def fail!(message_key)
      OmniAuth.config.on_failure.call(self.env, message_key.to_sym)
    end
  end
end