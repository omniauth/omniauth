require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Shelby.TV via OAuth and retrieve basic user information.
    # Usage:
    #    use OmniAuth::Strategies::Shelby, 'consumerkey', 'consumersecret'
    #
    class Shelby < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        super(app, :shelby, consumer_key, consumer_secret,
                {:site               => 'http://dev.shelby.tv',
                :request_token_path => "/oauth/request_token",
                :access_token_path  => "/oauth/access_token",
                :authorize_path     => "/oauth/authorize"}, options, &block)
      end
      
      # user info as supplied by Shelby
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/get_user_info').body)  #['Auth']['User']
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['_id'],
          'user_info' => user_info,
          'extra' => { 'user_hash' => user_hash }
        })
      end
      
      # user info according to schema
      def user_info
        { 
          'nickname' => user_hash['name'],
          'name' => user_hash['nickname']
        }
      end
      
    end
  end
end