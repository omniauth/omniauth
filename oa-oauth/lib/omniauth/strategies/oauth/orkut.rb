require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Orkut via OAuth and retrieve basic user info.
    #
    # Usage:
    #
    # use OmniAuth::Strategies::Orkut, 'consumerkey', 'consumersecret'
    #
    class Orkut < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://www.google.com',
          :request_token_path => '/accounts/OAuthGetRequestToken',
          :access_token_path => '/accounts/OAuthGetAccessToken',
          :authorize_path => '/accounts/OAuthAuthorizeToken'
        }
        super(app, :orkut, consumer_key, consumer_secret, client_options, options)
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
            'uid' => entry['id'],
            'first_name' => entry['name']['givenName'],
            'last_name' => entry['name']['familyName'],
            'image' => entry['thumbnailUrl']
          }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get("http://www.orkut.com/social/rest/people/@me/@self").body)
      end
        
      def request_phase
        request_token = consumer.get_request_token({:oauth_callback => callback_url}, {:scope => 'http://orkut.gmodules.com/social/rest'})
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
