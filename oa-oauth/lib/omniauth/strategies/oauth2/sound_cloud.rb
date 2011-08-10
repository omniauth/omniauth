require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to SoundCloud via OAuth2 and retrieve basic
    # user information.
    #
    # Usage:
    #    use OmniAuth::Strategies::SoundCloud, 'consumerkey', 'consumersecret'
    class SoundCloud < OmniAuth::Strategies::OAuth2
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :site => 'https://api.soundcloud.com',
          :authorize_url => 'https://soundcloud.com/connect',
          :token_url => 'https://api.soundcloud.com/oauth2/token'
        }
        super(app, :soundcloud, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_hash['id'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_hash,
            }
          }
        )
      end

      def user_info
        user_hash = self.user_hash
        {
          'name' => user_hash['full_name'],
          'nickname' => user_hash['username'],
          'location' => user_hash['city'],
          'description' => user_hash['description'],
          'image' => user_hash['avatar_url'],
          'urls' => {
            'Website' => user_hash['website'],
          },
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/me.json').body)
      end

      # OAuth2 by default uses 'Bearer %s' in the header
      def build_access_token
        access_token = super
        access_token.options[:header_format] = "OAuth %s"
        access_token
      end

    end
  end
end
