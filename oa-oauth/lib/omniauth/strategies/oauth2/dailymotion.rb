require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Dailymotion utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Dailymotion, 'API Key', 'Secret Key'
    class Dailymotion < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :site => 'https://api.dailymotion.com',
          :authorize_url => '/oauth/authorize',
          :token_url => '/oauth/token'
        }

        super(app, :dailymotion, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['id'],
          'screenaname' => user_data['screenaname'],
          'credentials' => {'expires_at' => @access_token.expires_at},
          'extra' => {'user_hash' => user_data}
        })
      end

      def user_data
        @data ||= @access_token.get('/me').parsed
      end
    end
  end
end
