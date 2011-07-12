require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Glitch < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)

        # :scope (identity|read|write) is required for authorization and should be passed
        # in the OmniAuth :provider options hash in your application

        client_options = {
          :site => 'http://api.glitch.com',
          :authorize_url => '/oauth2/authorize',
          :token_url => '/oauth2/token'
        }
        super(app, :glitch, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['player_tsid'],
            'user_info' => user_info,
            'extra' => user_data,
          }
        )
      end

      def user_data
        @access_token.options.merge!({:param_name => 'oauth_token', :mode => :query})
        response = @access_token.post('/simple/players.info')
        @data ||= MultiJson.decode(response.body)
      end

      def user_info
        {
          'name' => user_data['user_name'],
          'nickname' => user_data['player_name'],
          'image' => user_data['avatar_url'],
        }
      end
    end
  end
end
