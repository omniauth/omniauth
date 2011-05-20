require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # OAuth 2.0 based authentication with Google.
    class GoogleOAuth2 < OAuth2
      # @param [Rack Application] app standard middleware application argument
      # @param [String] client_id the application ID for your client
      # @param [String] client_secret the application secret
      # @option options [String] :scope ('https://www.google.com/m8/feeds/') space-separated services that you need. It is required to include the m8 service in order to retrieve the user email
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://accounts.google.com',
          :authorize_path => '/o/oauth2/auth',
          :access_token_path => '/o/oauth2/token'
        }

        super(app, :google2, client_id, client_secret, client_options, options, &block)
      end

      def request_phase
        options[:scope] ||= "https://www.google.com/m8/feeds/"
        redirect client.web_server.authorize_url(
          {:redirect_uri => callback_url, :response_type => "code"}.merge(options))
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_info['uid'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data}
        })
      end
      
      def user_info
        email = user_data['feed']['id']['$t']
        name = user_data['feed']['author'].first['name']['$t']
        name = email if name.strip == '(unknown)'
      
        {
          'email' => email,
          'uid' => email,
          'name' => name
        }
      end
      
      def user_data
        # From original Google OAuth strategy
        # Google is very strict about keeping authorization and
        # authentication separated.
        # They give no endpoint to get a user's profile directly that I can
        # find. We *can* get their name and email out of the contacts feed,
        # however. It will fail in the extremely rare case of a user who has
        # a Google Account but has never even signed up for Gmail. This has
        # not been seen in the field.
        @data ||= MultiJson.decode(
          @access_token.get("https://www.google.com/m8/feeds/contacts/default/full?max-results=1&alt=json"))
      end

    end
  end
end