require 'json'

module OmniAuth
  module Strategies
    # A convenience wrapper on AuthElsewhere::OAuth to allow you
    # to declare Twitter more simply.
    #
    # Usage:
    #
    #     use AuthElsewhere::Twitter, 'consumerkey', 'consumersecret'
    #
    class Twitter < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key, consumer_secret)
        super(app, :twitter, consumer_key, consumer_secret,
                :site => 'https://api.twitter.com')
      end
      
      def user_hash
        @user_hash ||= JSON.parse(@access_token.get('/1/account/verify_credentials.json'), :symbolize_keys => true)
      end
      
      def unique_id
        @access_token.params[:user_id]
      end
      
      def user_info
        {
          :name => user_hash[:name],
          :image => user_hash[:profile_image_url],
          :screen_name => user_hash[:screen_name],
          :description => user_hash[:description]
        }
      end
    end
  end
end