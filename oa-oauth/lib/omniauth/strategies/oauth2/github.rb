require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # OAuth 2.0 based authentication with GitHub. In order to
    # sign up for an application, you need to [register an application](http://github.com/account/applications/new)
    # and provide the proper credentials to this middleware.
    class GitHub < OmniAuth::Strategies::OAuth2
      # @param [Rack Application] app standard middleware application argument
      # @param [String] client_id the application ID for your client
      # @param [String] client_secret the application secret
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :site => 'https://api.github.com',
          :authorize_url => 'https://github.com/login/oauth/authorize',
          :token_url => 'https://github.com/login/oauth/access_token'
        }
        super(app, :github, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['id'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_data,
            },
          }
        )
      end

      def user_data
        @access_token.options[:mode] = :query
        @data ||= @access_token.get('/user').parsed
      end

      def user_info
        {
          'nickname' => user_data['login'],
          'email' => user_data['email'],
          'name' => user_data['name'],
          'urls' => {
            'GitHub' => "http://github.com/#{user_data['login']}",
            'Blog' => user_data['blog'],
          },
        }
      end
    end
  end
end
