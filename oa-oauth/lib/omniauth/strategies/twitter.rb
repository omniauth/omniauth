require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # 
    # Authenticate to Twitter via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Twitter, 'consumerkey', 'consumersecret'
    #
    class Twitter < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key, consumer_secret)
        super(app, :twitter, consumer_key, consumer_secret,
                :site => 'https://api.twitter.com')
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token.params[:user_id],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end
      
      def user_info
        user_hash = self.user_hash
        
        {
          'nickname' => user_hash['screen_name'],
          'name' => user_hash['name'],
          'location' => user_hash['location'],
          'image' => user_hash['profile_image_url'],
          'description' => user_hash['description'],
          'urls' => {'Website' => user_hash['url']}
        }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/1/account/verify_credentials.json').body)
      end

      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        (session[:oauth]||={})[name.to_sym] = {:callback_confirmed => request_token.callback_confirmed?, :request_token => request_token.token, :request_secret => request_token.secret}
        r = Rack::Response.new

        # For "Sign in with Twitter" request tokens should be sent
        # to oauth/autenticate instead of oauth/authorize.
        # See http://dev.twitter.com/pages/sign_in_with_twitter
        r.redirect request_token.authorize_url.gsub('authorize', 'authenticate')
        r.finish
      end

    end
  end
end
