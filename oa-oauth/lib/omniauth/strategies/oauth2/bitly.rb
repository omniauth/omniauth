require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Bitly utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Bitly, 'API Key', 'Secret Key'
    class Bitly < OmniAuth::Strategies::OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered on Bitly](http://bit.ly/a/account)
      # @param [String] client_secret the application secret as [registered on Bitly](http://bit.ly/a/account)
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://bit.ly/oauth/authorize',
          :token_url => 'https://api-ssl.bit.ly/oauth/access_token',
        }
        super(app, :bitly, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => @access_token['login'],
            'user_info' => user_data,
            'extra' => {
              'user_hash' => user_data,
            },
          }
        )
      end

      def user_data
        {
          'login' => @access_token['login'],
          'client_id' => @access_token['apiKey'],
        }
      end
    end
  end
end
