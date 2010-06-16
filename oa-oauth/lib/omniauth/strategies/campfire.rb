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
    class Campfire < OAuth2
      
      CAMPFIRE_SUBDOMAIN_PARAMETER = 'subdomain'
      
      def initialize(app, app_id, app_secret, options = {})
        super(app, :campfire, app_id, app_secret, options)
      end
      
      protected
      
      def request_phase
        if env['REQUEST_METHOD'] == 'GET'
          ask_for_campfire_subdomain
        else
          super(options.merge(:site => campfire_url))
        end
      end
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get('/users/me.json'))
      end
      
      def ask_for_campfire_subdomain
        OmniAuth::Form.build(title) do
          text_field 'Campfire Subdomain', CAMPFIRE_SUBDOMAIN_PARAMETER
        end.to_response
      end
      
      def campfire_url
        subdomain = request.params[CAMPFIRE_SUBDOMAIN_PARAMETER]
        'http://#{subdomain}.campfirenow.com'
      end
      
      def auth_hash
        user_hash = MultiJson.decode(@response.body)['user']
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['id'],
          'user_info' => user_info(user_hash),
          'credentials' => {
            'token' => user_hash['api_auth_token']
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
