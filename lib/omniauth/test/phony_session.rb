module OmniAuth
  module Test
    class PhonySession
      def initialize(app)
        @app = app
      end

      def call(env)
        @session ||= (env[OmniAuth.config.session_key] || {})
        env[OmniAuth.config.session_key] = @session
        @app.call(env)
      end
    end
  end
end
