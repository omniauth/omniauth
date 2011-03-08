require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # 
    # Authenticate to Doit.im via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Doit, 'consumer_key', 'consumer_secret'
    #
    class Doit < OmniAuth::Strategies::OAuth
      # Initialize the middleware
      #
      # @option options [Boolean, true] :sign_in When true, use the "Sign in with Doit.im" flow instead of the authorization flow.
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://openapi.doit.im'
        }
        
        client_options[:authorize_path] = '/oauth/authenticate' unless options[:sign_in] == false
        super(app, :doit, consumer_key, consumer_secret, client_options, options)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token.params[:id],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end
      
      def user_info
        user_hash = self.user_hash
        
        {
          'language'=>user_hash['language'],
          'nickname' => user_hash['nickname'],
          'name' => user_hash['username'],
          'account'=>user_hash['account'],
          'email'=>user_hash['remind_email'],
          'updated_at'=>user_hash['updated_at'],
          'timezone'=>user_hash['user_timezone'],
          'week_start'=>user_hash['week_start']
        }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/v1/settings').body)
      end
    end
  end
end
