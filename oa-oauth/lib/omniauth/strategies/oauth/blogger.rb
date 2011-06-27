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
    class Blogger < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://www.google.com/accounts/OAuthAuthorizeToken',
          :token_url => 'https://www.google.com/accounts/OAuthGetAccessToken',
        }
        super(app, :blogger, consumer_key, consumer_secret, client_options, options)
      end

      def auth_hash
        ui = user_info
        OmniAuth::Utils.deep_merge(super, {
          'uid' => ui['uid'],
          'user_info' => ui,
          'extra' => {'user_hash' => user_hash}
        })
      end

			#TODO: Remove contact list from hash returned to the application
      def user_info
        {
          'uid' => user_hash['feed']['author'][0]['email']['$t'],
          'nickname' => user_hash['feed']['author'][0]['name']['$t']
        }
      end

      def user_hash
        # Using Contact feed
        @user_hash ||= MultiJson.decode(@access_token.get("https://www.google.com/m8/feeds/contacts/default/full/?alt=json").body)
      end
    end
  end
end
