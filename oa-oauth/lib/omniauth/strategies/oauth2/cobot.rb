require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Cobot utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Cobot, 'Client ID', 'Client Secret'
    class Cobot < OmniAuth::Strategies::OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered on Cobot](https://www.cobot.me/oauth2_clients)
      # @param [String] client_secret the application secret as [registered on Cobot](https://www.cobot.me/oauth2_clients)
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://www.cobot.me/oauth2/authorize',
          :token_url => 'https://www.cobot.me/oauth2/access_token'
        }
        super(app, :cobot, client_id, client_secret, client_options, {:scope => 'read write'}.merge(options), &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['login'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_data,
            }
          }
        )
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('https://www.cobot.me/api/user').body)
      end

      # OAuth2 by default uses 'Bearer %s' in the header
      def build_access_token
        access_token = super
        access_token.options[:header_format] = "OAuth %s"
        access_token
      end

      def user_info
        {
          'name'  => user_data['login'],
          'email' => user_data['email']
        }
      end
    end
  end
end
