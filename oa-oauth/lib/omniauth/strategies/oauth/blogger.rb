# Based heavily on the Google strategy, monkeypatch and all
require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to YouTube via OAuth and retrieve basic user info.
    #
    # Usage:
    #    use OmniAuth::Strategies::YouTube, 'consumerkey', 'consumersecret'
    class Blogger < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/accounts/OAuthGetAccessToken',
          :authorize_path => '/accounts/OAuthAuthorizeToken',
          :request_token_path => '/accounts/OAuthGetRequestToken',
          :site => 'https://www.google.com',
        }
        super(app, :blogger, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        ui = user_info
        OmniAuth::Utils.deep_merge(super, {
          'uid' => ui['uid'],
          'user_info' => ui,
          'extra' => {'user_hash' => user_hash},
        })
      end

      # TODO: Remove contact list from hash returned to the application
      def user_info
        {
          'uid' => user_hash['feed']['author'][0]['email']['$t'],
          'nickname' => user_hash['feed']['author'][0]['name']['$t'],
        }
      end

      def user_hash
        # Using Contact feed
        @user_hash ||= MultiJson.decode(@access_token.get('https://www.google.com/m8/feeds/contacts/default/full/?alt=json').body)
      end

      def request_phase
        request_token = consumer.get_request_token({:oauth_callback => callback_url}, {:scope => 'http://www.blogger.com/feeds/ http://www.google.com/m8/feeds/'})
        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {'callback_confirmed' => request_token.callback_confirmed?, 'request_token' => request_token.token, 'request_secret' => request_token.secret}
        r = Rack::Response.new
        if request_token.callback_confirmed?
          r.redirect(request_token.authorize_url)
        else
          r.redirect(request_token.authorize_url(:oauth_callback => callback_url))
        end
        r.finish
      end
    end
  end
end
