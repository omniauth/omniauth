require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Vimeo via OAuth and retrieve basic user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Vimeo, 'consumerkey', 'consumersecret'
    #
    class Vimeo < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/oauth/access_token',
          :authorize_path => '/oauth/authorize',
          :request_token_path => '/oauth/request_token',
          :site => 'http://vimeo.com',
        }
        super(app, :vimeo, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        user = user_hash['person']
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user['id'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user,
            },
          }
        )
      end

      def user_info
        user = user_hash['person']
        {
          'nickname' => user['username'],
          'name' => user['display_name'],
          'location' => user['location'],
          'description' => user['bio'],
          'image' => user['portraits']['portrait'].select{|h| h['height'] == '300'}.first['_content'],
          'urls' => {
            'website' => user['url'],
            'vimeo' => user['profileurl'],
          },
        }
      end

      def user_hash
        url = 'http://vimeo.com/api/rest/v2?method=vimeo.people.getInfo&format=json'
        @user_hash ||= MultiJson.decode(@access_token.get(url).body)
      end
    end
  end
end
