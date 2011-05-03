module OmniAuth
  module Strategies
    # The identity strategy allows you to provide simple internal 
    # user authentication using the same process flow that you
    # use for external OmniAuth providers.
    class Identity
      include OmniAuth::Strategy
 
      # @option options [Symbol] :name The name you want to use for this strategy.
      # @option options [Symbol] :model The class you wish to use as the identity model.
      def initialize(app, options = {})
        super(app, options[:name] || :identity, options.dup)
      end

      def request_phase
        OmniAuth::Form.build(
          :title => (options[:title] || "Identity Verification"),
          :url => callback_path
        ) do
          text_field 'Login', 'auth_key'
          password_field 'Password', 'password'
        end.to_response 
      end

      def callback_phase
        return fail!(:invalid_credentials) unless identity
        super
      end

      def auth_hash 
        {
          'provider' => name,
          'uid' => identity.uid,
          'user_info' => identity.user_info
        }
      end
      
      def identity
        @identity ||= model.authenticate(request['auth_key'], request['password'])
      end

      def model
        options[:model] || ::Identity
      end
    end
  end
end
