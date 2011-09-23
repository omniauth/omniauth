require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Kaixin001 utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # OAuth 2.0 - Kaixin001 Documentation
    # http://wiki.open.kaixin001.com/
    # 
    # Apply kaixin001 key here:
    # http://www.kaixin001.com/platform/rapp/rapp.php
    #
    # @example Basic Usage of Kaixin001
    #
    #   use OmniAuth::Strategies::Kaixin001, 'API_Key', 'Secret_Key'
    class Kaixin001 < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :site          => 'https://api.kaixin001.com/',
          :authorize_url => '/oauth2/authorize',
          :token_url     => '/oauth2/access_token',
          :token_method  => :get
        }
        
        super(app, :kaixin001, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash                
          OmniAuth::Utils.deep_merge(
            super, 
            {
              'uid' => user_data['uid'],
              'user_info' => user_info,
              'extra' => {
                'user_hash' => user_data,
              }
            }
          )        
      end       

      def user_data
        @data ||= MultiJson.decode(@access_token.get("/users/me.json?access_token=#{@access_token.token}").body)
      end

      def user_info
        {
          'uid'    => user_data['uid'],
          'name'   => user_data['name'],
          'gender' => user_data['gender'],
        }
      end
    end
  end
end
