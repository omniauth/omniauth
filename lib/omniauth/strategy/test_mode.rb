module OmniAuth
  module Strategy
    # Runs the request and callback phases against OmniAuth.config.mock_auth
    # instead of the provider when OmniAuth.config.test_mode is enabled.
    module TestMode
      # This is called in lieu of the normal request process
      # in the event that OmniAuth has been configured to be
      # in test mode.
      def mock_call!(*)
        if request_call?
          mock_request_call
        elsif on_callback_path?
          mock_callback_call
        else
          call_app!
        end
      rescue StandardError => e
        handle_phase_error(e)
      end

      def mock_request_call
        setup_phase

        run_hook(:request_validation_phase)

        session['omniauth.params'] = request.GET

        run_hook(:before_request_phase)

        store_origin if options.origin_param

        result = redirect(callback_url)

        run_hook(:after_request_phase)
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
        run_hook(:before_callback_phase)
        failed ? fail!(mocked_auth) : call_app!
      end
    end
  end
end
