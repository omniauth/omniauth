require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Windows Connect utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # OAuth 2.0 - MS Documentation
    # http://msdn.microsoft.com/en-us/library/hh243647.aspx
    #
    # Sign-up for account:
    # http://go.microsoft.com/fwlink/?LinkId=213332
    # 
    # @example Basic Usage of Liveid
    #
    #   use OmniAuth::Strategies::Liveid, 'client_id', 'client_secret'
    class Liveid < OmniAuth::Strategies::OAuth2
      # @option options [String] :scope separate the scopes by a space
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://oauth.live.com/authorize',
          :token_url => 'https://oauth.live.com/token'
        }
        
        super(app, :liveid, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash                
          OmniAuth::Utils.deep_merge(
            super, 
            {
              'uid' => user_data['id'],
              'user_info' => user_info,
              'extra' => {
                'user_hash' => user_data,
              }
            }
          )        
      end       

      def request_phase
        options[:scope] ||= 'wl.signin wl.basic'
        options[:response_type] ||= 'code'
        super
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('https://apis.live.net/v5.0/me').body)
      end

      def user_info
        {
          'id' => user_data['id'],
          'name' => user_data['name'],
          'email' => '',
          'first_name' => user_data['first_name'],
          'last_name' => user_data['last_name'],
          'link' => user_data['link'],
          'gender' => user_data['gender'],
          'locale' => user_data['locale']                    
        }
      end
            
    end
  end
end
