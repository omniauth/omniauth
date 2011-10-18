require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Rdio via OAuth and retrieve basic user information.
    #
    # Usage:
    #    use OmniAuth::Strategies::Rdio, 'consumerkey', 'consumersecret'
    class Rdio < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/oauth/access_token',
          :authorize_url => 'https://www.rdio.com/oauth/authorize',
          :request_token_path => '/oauth/request_token',
          :site => 'http://api.rdio.com',
        }
        super(app, :rdio, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_hash['key'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_hash,
            },
          }
        )
      end

      def user_info
        user = user_hash
        {
          'nickname' => user['username'],
          'first_name' => user['firstName'],
          'last_name' => user['lastName'],
          'name' => "#{user['firstName']} #{user['lastName']}"
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.post('http://api.rdio.com/1/', {:method => 'currentUser', :extras => 'username'}).body)['result']
      end
    end
  end
end
