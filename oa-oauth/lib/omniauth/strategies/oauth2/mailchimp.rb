require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Mailchimp < OmniAuth::Strategies::OAuth2
      
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://login.mailchimp.com/oauth2/authorize',
          :token_url => 'https://login.mailchimp.com/oauth2/token',
        }
        super(app, :mailchimp, client_id, client_secret, client_options, options, &block)
      end
      
      def auth_hash
        data = user_data
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => @access_token.client.id,
            'extra'=> {
              'user_hash' => data
            }
          }
        )
      end

      def user_data
        @data ||=  MultiJson.decode(@access_token.get("https://login.mailchimp.com/oauth2/metadata").body)
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