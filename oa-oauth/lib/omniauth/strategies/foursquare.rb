require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Foursquare < OAuth2
      # Initialize the middleware
      #
      # @option options [Boolean, true] :sign_in When true, use a sign-in flow instead of the authorization flow.
      # @option options [Boolean, false] :mobile When true, use the mobile sign-in interface.
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        super(app, :foursquare, client_id, client_secret, {
          :site => {
            :url => "https://api.foursquare.com/v2",
            :ssl => {
              :verify => OpenSSL::SSL::VERIFY_NONE
            }
          },
          :authorize_url      => "https://foursquare.com/oauth2/authenticate",
          :access_token_url   => "https://foursquare.com/oauth2/access_token"
        }, options, &block)
      end
      
      def request_phase
        options[:response_type] ||= 'code'
        super
      end
      
      def callback_phase
        options ||= {
          'client_id' => client_id,
          'client_secret' => client_secret,
          'grant_type' => 'authorization_code'
        }
        super
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['response']['user']['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end
      
      def user_info
        user_hash = self.user_hash['response']['user']
        
        {
          'nickname' => user_hash['contact']['twitter'],
          'first_name' => user_hash['firstName'],
          'last_name' => user_hash['lastName'],
          'email' => user_hash['contact']['twitter'],
          'name' => "#{user_hash['firstName']} #{user_hash['lastName']}".strip,
        # 'location' => user_hash['location'],
          'image' => user_hash['photo'],
        # 'description' => user_hash['description'],
          'phone' => user_hash['contact']['phone'],
          'urls' => {}
        }
      end
      
      def user_hash
        @user_hash ||= @access_token.get('https://api.foursquare.com/v2/users/self', {'oauth_token' => @access_token.token})
      end
    end
  end
end