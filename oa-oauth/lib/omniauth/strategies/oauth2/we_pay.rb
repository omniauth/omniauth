require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # OAuth 2.0 based authentication with WePay. In order to
    # sign up for an application, you need to [register an application](https://wepay.com/developer/register)
    # and provide the proper credentials to this middleware.
    class WePay < OmniAuth::Strategies::OAuth2
      # @param [Rack Application] app standard middleware application argument
      # @param [String] client_id the application ID for your client
      # @param [String] client_secret the application secret
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://www.wepay.com/session/authorize',
          :token_url => 'https://wepayapi.com/v1/oauth2/token',
        }
        super(app, :we_pay, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['user_id'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_data,
            },
          }
        )
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/v1/user'))['result']
      end

      def user_info
        {
          'email' => user_data['email'],
          'name' => "#{user_data['firstName']} #{user_data['lastName']}".strip,
          'first_name' => user_data['firstName'],
          'last_name' => user_data['lastName'],
          'image' => user_data['picture'],
        }
      end
    end
  end
end
