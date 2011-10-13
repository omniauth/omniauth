require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Salesforce < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :site => 'https://login.salesforce.com',
          :authorize_url  => '/services/oauth2/authorize',
          :token_url      => '/services/oauth2/token',
        }
        super(app, :salesforce, client_id, client_secret, client_options, options, &block)
      end
      
      def request_phase
        options[:response_type] ||= 'code'
        super
      end

      def callback_phase
        options[:grant_type] ||= 'authorization_code'
        super
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
        @access_token.options[:header_format] = 'OAuth %s'

        @data ||= @access_token.get(@access_token['id']).parsed
      rescue ::OAuth2::Error => e
        if e.response.status == 302
          @data ||= @access_token.get(e.response.headers['location']).parsed
        else
          raise e
        end
      end
    end
  end
end
