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
            :url => "https://api.foursquare.com/v2/",
            :ssl => {
              :verify => OpenSSL::SSL::VERIFY_NONE
            }
          },
          :authorize_url      => "https://foursquare.com/oauth2/authenticate?response_type=code",
          :access_token_url   => "https://foursquare.com/oauth2/access_token?grant_type=authorization_code"
        }, options, &block)
      end
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get('/users/self', {'oauth_token' => @access_token.token}))
      end
      
      def callback_phase
        options[:client_id] ||= client_id
        options[:client_secret] ||= client_secret
        
        log = Logger.new(STDOUT)
        log.level = Logger::DEBUG
        log.debug options
        
        super
      end
      
      def user_info
        {
          'nickname' => user_data['response']['user']['contact']['twitter'],
          'first_name' => user_data['response']['user']['firstName'],
          'last_name' => user_data['response']['user']['lastName'],
          'email' => user_data['response']['user']['contact']['twitter'],
          'name' => "#{user_data['response']['user']['firstName']} #{user_data['response']['user']['lastName']}".strip,
        # 'location' => user_data['response']['user']['location'],
          'image' => user_data['response']['user']['photo'],
        # 'description' => user_data['response']['user']['description'],
          'phone' => user_data['response']['user']['contact']['phone'],
          'urls' => {}
        }
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['response']['user']['response']['user']['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data['response']['user']}
        })
      end
    end
  end
end