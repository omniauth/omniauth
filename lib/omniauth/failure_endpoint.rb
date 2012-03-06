module OmniAuth
  class FailureEndpoint
    attr_reader :env

    def self.call(env)
      new(env).call
    end

    def initialize(env)
      @env = env
    end

    def call
      message_key = env['omniauth.error.type']
      new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}"
      [302, {'Location' => new_path, 'Content-Type'=> 'text/html'}, []]
    end
  end
end