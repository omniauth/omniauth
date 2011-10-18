require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Dropbox < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://www.dropbox.com/0/oauth/authorize',
          :access_token_url => 'https://api.dropbox.com/0/oauth/access_token',
          :proxy => ENV['HTTP_PROXY'] || ENV['http_proxy'],
          :request_token_url => 'https://api.dropbox.com/0/oauth/request_token',
          :site => 'https://api.dropbox.com',
        }
        super(app, :dropbox, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['uid'],
            'user_info' => user_info,
          }
        )
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/0/account/info').body)
      end

      def user_info
        {
          'name' => user_data['display_name'],
          'uid' => user_data['uid'],
          'email' => user_data['email']
        }
      end
    end
  end
end
