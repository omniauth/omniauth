module OmniAuth
  class SessionStore
    attr_reader :env

    def self.call(env)
      new(env)
    end

    def initialize(env)
      @env = env
    end

    def []= (key,value)
      session[key] = value
    end

    def [] (key)
      session[key]
    end

    def delete (key)
      session.delete(key)
    end

    protected

    def session
      @env['rack.session']
    end

  end
end