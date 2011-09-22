require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # OAuth 2.0 based authentication with Google.
    class GoogleOAuth2 < OAuth2
      # @param [Rack Application] app standard middleware application argument
      # @param [String] client_id the application ID for your client
      # @param [String] client_secret the application secret
      # @option options [String] :scope ('https://www.googleapis.com/auth/userinfo.email') space-separated services that you need.
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://accounts.google.com',
          :authorize_url => '/o/oauth2/auth',
          :token_url => '/o/oauth2/token'
        }

        super(app, :google_oauth2, client_id, client_secret, client_options, options, &block)
      end

      def request_phase
        google_email_scope = "www.googleapis.com/auth/userinfo.email"
        options[:scope] ||= "https://#{google_email_scope}"
        options[:scope] << " https://#{google_email_scope}" unless options[:scope] =~ %r[http[s]?:\/\/#{google_email_scope}]
        redirect client.auth_code.authorize_url(
          {:redirect_uri => callback_url, :response_type => "code"}.merge(options))
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_info['uid'],
          'user_info' => user_info,
          'credentials' => {'expires_at' => @access_token.expires_at},
          'extra' => {'user_hash' => user_data}
        })
      end

      def user_info
        if user_data['data']['isVerified']
          email = user_data['data']['email']
        else
          email = nil
        end
        {
          'email' => email,
          'uid' => email,
          'name' => email
        }
      end

      def user_data
        @data ||=
          @access_token.get("https://www.googleapis.com/userinfo/email?alt=json").parsed
      end

    end
  end
end
