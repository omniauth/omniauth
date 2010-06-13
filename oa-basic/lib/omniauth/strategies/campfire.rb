require 'omniauth/basic'
require 'multi_json'

module OmniAuth
  module Strategies
    class Campfire < HttpBasic
      def initialize(app)
        super(app, :campfire, nil)
      end
      
      def endpoint
        "http://#{request.params['user']}:#{request.params['password']}@#{request.params['subdomain']}.campfirenow.com/users/me.json"
      end
      
      def perform_authentication(endpoint)
        super(endpoint) rescue super(endpoint.sub('http','https'))
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
          'nickname' => request.params['user'],
          'name' => hash['name'],
          'email' => hash['email_address']
        }
      end
      
      def get_credentials
        OmniAuth::Form.build('Campfire Authentication') do
          text_field 'Subdomain', 'subdomain'
          text_field 'Username', 'user'
          password_field 'Password', 'password'
        end.to_response
      end
    end
  end
end
