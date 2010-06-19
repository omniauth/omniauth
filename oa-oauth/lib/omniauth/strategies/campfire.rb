require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Campfire utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Campfire, 'app_id', 'app_secret'
    class Campfire < ThirtySevenSignals
      
      def initialize(app, app_id, app_secret, options = {})
        super(app, :campfire, app_id, app_secret, options)
      end
      
      protected
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get('/users/me.json'))
      end
      
      def site_url
        "https://#{subdomain}.campfirenow.com"
      end
      
      def auth_hash
        data = self.user_data
        OmniAuth::Utils.deep_merge(super, {
          'uid' => data['user']['id'].to_s,
          'user_info' => user_info(data),
          'credentials' => {
            'token' => data['api_auth_token']
          },
          'extra' => {
            'access_token' => @access_token
          }
        })
      end
      
      def user_info(hash)
        {
          'name' => hash['name'],
          'email' => hash['email_address']
        }
      end
    end
    
  end
end
