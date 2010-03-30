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
      dup._call(env)
    end

    def _call(env)
      @env = env
      if request.path == "#{OmniAuth.config.path_prefix}/#{name}"
        request_phase
      elsif request.path == "#{OmniAuth.config.path_prefix}/#{name}/callback"
        callback_phase
      else
        @app.call(env)
      end
    end
    
    def request_phase
      raise NotImplementedError
    end
    
    def callback_phase
      raise NotImplementedError
    end
    
    def session
      @env['rack.session']
    end

    def request
      @request ||= Rack::Request.new(@env)
    end
    
    def user_info; {} end
    
    def fail!(message_key)
      OmniAuth.config.on_failure.call(self.env, message_key.to_sym)
    end
  end
end