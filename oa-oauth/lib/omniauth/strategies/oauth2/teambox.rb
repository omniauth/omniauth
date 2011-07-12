require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Teambox < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://teambox.com/oauth/authorize',
          :token_url => 'https://teambox.com/oauth/token',
        }
        super(app, :teambox, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['id'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_data
            },
          }
        )
      end

      def request_phase
        options[:scope] ||= 'offline_access'
        options[:response_type] ||= 'code'
        super
      end

      def callback_phase
        options[:grant_type] ||= 'authorization_code'
        super
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/api/1/account'))
      end

      def user_info
        {
          'nickname' => user_data['username'],
          'name' => user_data['first_name'],
          'image' => user_data['avatar_url'],
        }
      end
    end
  end
end
