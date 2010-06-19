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
      
      def client
        ::OAuth2::Client.new(@client.id, @client.secret, :site => campfire_url)
      end
      
      def request_phase
        if subdomain
          super
        else
          ask_for_campfire_subdomain
        end
      end
      
      def callback_phase
        if subdomain
          super
        else
          ask_for_campfire_subdomain
        end
      end
      
      def subdomain
        ((request.session[:oauth] ||= {})[:campfire] ||= {})[:subdomain] ||= request.params[CAMPFIRE_SUBDOMAIN_PARAMETER]
      end
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get('/users/me.json'))
      end
      
      def ask_for_campfire_subdomain
        OmniAuth::Form.build('Campfire Subdomain Required') do
          text_field 'Campfire Subdomain', ::OmniAuth::Strategies::Campfire::CAMPFIRE_SUBDOMAIN_PARAMETER
        end.to_response
      end
      
      def campfire_url
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
