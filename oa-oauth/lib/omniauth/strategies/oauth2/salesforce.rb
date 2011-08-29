require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Salesforce < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://login.salesforce.com/services/oauth2/authorize',
          :token_url => 'https://login.salesforce.com/services/oauth2/token',
        }
        options.merge!(:response_type => 'code', :grant_type => 'authorization_code')
        super(app, :salesforce, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        data = user_data
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => @access_token['id'],
            'credentials' => {
              'issued_at' => @access_token['issued_at'],
              'refresh_token' => @access_token.refresh_token,
              'instance_url' => @access_token['instance_url'],
              'signature' => @access_token['signature'],
            },
            'extra' => {
              'user_hash' => data,
            },
            'user_info' => {
              'email' => data['email'],
              'name' => data['display_name'],
            },
          }
        )
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get(@access_token['id']))
      rescue ::OAuth2::Error => e
        if e.response.status == 302
          @data ||= MultiJson.decode(@access_token.get(e.response.headers['location']))
        else
          raise e
        end
      end
    end
  end
end
