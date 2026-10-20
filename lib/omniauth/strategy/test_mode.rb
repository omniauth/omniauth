module OmniAuth
  module Strategy
    # Runs the request and callback phases against OmniAuth.config.mock_auth
    # instead of the provider when OmniAuth.config.test_mode is enabled.
    module TestMode
      # This is called in lieu of the normal request process
      # in the event that OmniAuth has been configured to be
      # in test mode.
      def mock_call!(*)
        begin
          return mock_request_call if on_request_path? && OmniAuth.config.allowed_request_methods.include?(request.request_method.downcase.to_sym)
          return mock_callback_call if on_callback_path?
        rescue StandardError => e
          raise e if env.delete('omniauth.error.app')

          return fail!(e.message, e)
        end

        call_app!
      end

      def mock_request_call
        setup_phase

        OmniAuth.config.request_validation_phase.call(env) if OmniAuth.config.request_validation_phase

        session['omniauth.params'] = request.GET

        OmniAuth.config.before_request_phase.call(env) if OmniAuth.config.before_request_phase

        store_origin if options.origin_param

        result = redirect(callback_url)

        OmniAuth.config.after_request_phase.call(env) if OmniAuth.config.after_request_phase
        result
      end

      def mock_callback_call
        setup_phase

        origin = session.delete('omniauth.origin')
        @env['omniauth.origin'] ||= origin
        @env['omniauth.origin'] = nil if env['omniauth.origin'] == ''
        @env['omniauth.params'] = session.delete('omniauth.params') || {}

        mocked_auth = OmniAuth.mock_auth_for(name.to_s)
        failed = mocked_auth.is_a?(Symbol)
        @env['omniauth.auth'] = mocked_auth unless failed
        OmniAuth.config.before_callback_phase.call(@env) if OmniAuth.config.before_callback_phase
        failed ? fail!(mocked_auth) : call_app!
      end
    end
  end
end
