require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Gowalla utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Gowalla, 'API Key', 'Secret Key'
    class Gowalla < OmniAuth::Strategies::OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered on Gowalla](http://gowalla.com/api/keys)
      # @param [String] client_secret the application secret as [registered on Gowalla](http://gowalla.com/api/keys)
      # @option options ['read','read-write'] :scope ('read') the scope of your authorization request; must be `read` or `read-write`
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://gowalla.com/api/oauth/new',
          :token_url => 'https://api.gowalla.com/api/oauth/token',
        }
        super(app, :gowalla, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['url'].split('/').last,
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_data,
              'refresh_token' => refresh_token,
              'token_expires_at' => token_expires_at,
            },
          }
        )
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/users/me.json'))
      end

      def refresh_token
        @refresh_token ||= @access_token.refresh_token
      end

      def token_expires_at
        @expires_at ||= @access_token.expires_at
      end

      def request_phase
        options[:scope] ||= 'read'
        super
      end

      def user_info
        {
          'name' => "#{user_data['first_name']} #{user_data['last_name']}",
          'nickname' => user_data['username'],
          'first_name' => user_data['first_name'],
          'last_name' => user_data['last_name'],
          'location' => user_data['hometown'],
          'description' => user_data['bio'],
          'image' => user_data['image_url'],
          'urls' => {
            'Gowalla' => "http://www.gowalla.com#{user_data['url']}",
            'Website' => user_data['website'],
          },
        }
      end
    end
  end
end
