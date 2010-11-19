require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Foursquare < OAuth
      # Initialize the middleware
      #
      # @option options [Boolean, true] :sign_in When true, use a sign-in flow instead of the authorization flow.
      # @option options [Boolean, false] :mobile When true, use the mobile sign-in interface.
      def initialize(app, consumer_key, consumer_secret, options = {})
        client_options = {:site => 'http://foursquare.com'}
        
        auth_path = (options[:sign_in] == false) ? '/oauth/authorize' : '/oauth/authenticate'
        auth_path = "/mobile#{auth_path}" if options[:mobile]
        
        client_options[:authorize_path] = auth_path
        
        super(app, :foursquare, consumer_key, consumer_secret, client_options, options)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end
      
      def user_info
        user_hash = self.user_hash
        
        {
          'nickname' => user_hash['twitter'],
          'first_name' => user_hash['firstname'],
          'last_name' => user_hash['lastname'],
          'email' => user_hash['email'],
          'name' => "#{user_hash['firstname']} #{user_hash['lastname']}".strip,
        # 'location' => user_hash['location'],
          'image' => user_hash['photo'],
        # 'description' => user_hash['description'],
          'phone' => user_hash['phone'],
          'urls' => {}
        }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('http://api.foursquare.com/v1/user.json').body)['user']
      end
    end
  end
end