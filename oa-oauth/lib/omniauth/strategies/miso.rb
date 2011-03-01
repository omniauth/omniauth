require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # 
    # Authenticate to Miso via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Miso, 'consumerkey', 'consumersecret'
    #
    class Miso < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        super(app, :miso, consumer_key, consumer_secret,
                {:site => 'https://gomiso.com',
                :authorize_path => '/oauth/authorize'}, options, &block)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token.params[:user_id],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end
      
      def user_info
        user_hash = self.user_hash["user"]
        
        {
          'nickname' => user_hash['username'],
          'name' => user_hash['full_name'],
          'image' => user_hash['profile_image_url'],
          'description' => user_hash['tagline'],
        }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/api/oauth/v1/users/show.json').body)
      end
    end
  end
end
