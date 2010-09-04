require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # 
    # Authenticate to TypePad via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::TypePad, 'consumerkey', 'consumersecret', 'application_id'
    #
    class TypePad < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key, consumer_secret, application_id)
        # You *must* use query_string for the token dance.
        super(app, :type_pad, consumer_key, consumer_secret,
          :site => 'https://www.typepad.com',
          :request_token_path => '/secure/services/oauth/request_token',
          :access_token_path => '/secure/services/oauth/access_token',
          :authorize_path => "/secure/services/api/#{application_id}/oauth-approve",
          :http_method => :get,
          :scheme => :query_string)
      end
      
      def auth_hash
        ui = user_info
        OmniAuth::Utils.deep_merge(super, {
          'uid' => ui['uid'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end
      
      def user_info
        user_hash = self.user_hash
        
        {
          'uid' => user_hash['urlId'],
          'nickname' => user_hash['preferredUsername'],
          'name' => user_hash['displayName'],
          'image' => user_hash['avatarLink']['url'],
          'description' => user_hash['aboutMe'],
          'urls' => {'Profile' => user_hash['profilePageUrl']}
        }
      end
      
      def user_hash
        # For authenticated requests, you have to use header as your scheme
        self.consumer.options[:scheme] = :header

        @user_hash ||= MultiJson.decode(@access_token.get("https://api.typepad.com/users/@self.json").body)
      end
    end
  end
end

