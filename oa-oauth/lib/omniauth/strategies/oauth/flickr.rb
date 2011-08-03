require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies

    class Flickr < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        scope = options.delete(:scope) || 'read'
        options[:authorize_params] ||= {}
        options[:authorize_params][:perms] = scope

        client_options = {
          :access_token_path => "/services/oauth/access_token",
          :authorize_path => "/services/oauth/authorize",
          :request_token_path => "/services/oauth/request_token",
          :site => "http://www.flickr.com"
        }
        super(app, :flickr, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => @access_token.params["user_nsid"],
            'user_info' => user_info
          }
        )
      end

      def user_info
        {
          'username' => @access_token.params["username"],
          'full_name' => @access_token.params["fullname"]
        }
      end
    end
  end
end
