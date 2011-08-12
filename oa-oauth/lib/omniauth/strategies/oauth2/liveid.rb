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
    # @example Basic Usage
    #
    #   use OmniAuth::Strategies::Liveid, 'client_id', 'client_secret'
    class Liveid < OmniAuth::Strategies::OAuth2
      # @option options [String] :scope separate the scopes by a space
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {                    
          :site => 'https://oauth.live.com',
          :authorize_url => 'https://oauth.live.com/authorize',
          :token_url => 'https://oauth.live.com/token'
        }
        
        super(app, :liveid, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
          options[:scope] ||= 'wl.signin,wl.basic'
          options[:response_type] ||= 'code'
          options[:display] ||= 'popup'
          
        
          OmniAuth::Utils.deep_merge(
            super, 
            {
              'provider' => name.to_s,
              'uid' => nil,
              'name' => client.token_url({:redirect_uri => callback_url}.merge(options)) ,
              'id' => @access_token
            }
          )        
      end       

      def request_phase
        options[:scope] ||= 'wl.signin wl.basic'
        options[:response_type] ||= 'code'
        options[:display] ||= 'popup'
#        options[:ssl] ||= false
        super
      end


      def user_data
#        @data ||= MultiJson.decode(@access_token.get('/me'))
        @data ||= @access_token.get('/me')
      end

      def user_info
        {
          'id' => user_data['data']['id'],
          'name' => user_data['data']['name'],
          'first_name' => user_data['data']['first_name'],
          'last_name' => user_data['data']['last_name'],
          'link' => user_data['data']['link'],
          'gender' => user_data['data']['gender'],
          'locale' => user_data['data']['locale']                    
        }
      end
      
    end
  end
end
