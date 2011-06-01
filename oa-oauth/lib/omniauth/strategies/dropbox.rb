require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Dropbox < OmniAuth::Strategies::OAuth
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        client_options = {
          :site => "https://api.dropbox.com",
          :proxy => ENV["HTTP_PROXY"] || ENV["http_proxy"],
          :request_token_url => "https://api.dropbox.com/0/oauth/request_token",
          :authorize_url      => "https://www.dropbox.com/0/oauth/authorize",
          :access_token_url   => "https://api.dropbox.com/0/oauth/access_token"
        }
        super(app, :dropbox, client_id, client_secret, client_options, options, &block)
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/0/account/info').body)
      end

      def user_info
        {
          'name' => "#{user_data['display_name']}"
        }
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['uid'],
          'user_info' => user_info
        })
      end
    end
  end
end
