require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to TSina via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::TSina, 'APIKey', 'APIKeySecret'
    #
    class Tsina < OmniAuth::Strategies::OAuth
      
      class << self
        def api_key
          @@api_key
        end

        def secret_key
          @@secret_key
        end
        
      end
      
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        @@api_key = consumer_key
        @@secret_key = consumer_secret
        
        client_options = {
          :site               => 'http://api.t.sina.com.cn',
          :request_token_path => '/oauth/request_token',
          :access_token_path  => '/oauth/access_token',
          :authorize_path     => '/oauth/authorize',
          # :realm              => 'OmniAuth'
        }

        super(app, :tsina, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        # raise @access_token.inspect
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token.params[:id],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      
      def user_info
        user_hash = self.user_hash
        raise user_hash.inspect
      end

      def user_hash
        # http://api.t.sina.com.cn/users/show/:id.json?source=appkey
        # @access_token.params[:id] is the UID
        # Tsina.api_key is the appkey
        uid = @access_token.params[:id]
        raise @access_token.inspect
        @user_hash ||= MultiJson.decode(@access_token.get("http://api.t.sina.com.cn/users/show/#{uid}.json?source=#{Tsina.api_key}").body)
      end
    end
  end
end
