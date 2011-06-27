# Based heavily on the Google strategy, monkeypatch and all

require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to YouTube via OAuth and retrieve basic user info.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::YouTube, 'consumerkey', 'consumersecret'
    #
    class YouTube < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://www.google.com/accounts/OAuthAuthorizeToken',
          :token_url => 'https://www.google.com/accounts/OAuthGetAccessToken',
        }
        super(app, :you_tube, consumer_key, consumer_secret, client_options, options)
      end

      def auth_hash
        ui = user_info
        OmniAuth::Utils.deep_merge(super, {
          'uid' => ui['uid'],
          'user_info' => ui,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        entry = user_hash['entry']
        {
          'uid' => entry['id']['$t'],
          'nickname' => entry['author'].first['name']['$t'],
          'first_name' => entry['yt$firstName'] && entry['yt$firstName']['$t'],
          'last_name' => entry['yt$lastName'] && entry['yt$lastName']['$t'],
          'image' => entry['media$thumbnail'] && entry['media$thumbnail']['url'],
          'description' => entry['yt$description'] && entry['yt$description']['$t'],
          'location' => entry['yt$location'] && entry['yt$location']['$t']
        }
      end

      def user_hash
        # YouTube treats 'default' as the currently logged-in user
        # via http://apiblog.youtube.com/2010/11/update-to-clientlogin-url.html
        @user_hash ||= MultiJson.decode(@access_token.get("http://gdata.youtube.com/feeds/api/users/default?alt=json").body)
      end
    end
  end
end
