require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class GitHub < OAuth2
      def initialize(app, app_id, app_secret, options = {})
        local_options = {
          :site => 'https://github.com/',
          :authorize_path => '/login/oauth/authorize',
          :access_token_path => '/login/oauth/access_token'
        }
        local_options.merge!(options)
        super(app, :github, app_id, app_secret, local_options)
      end
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get('/api/v2/json/user/show'))['user']
      end
      
      def user_info
        {
          'nickname' => user_data["login"],
          'email' => user_data['email'],
          'name' => user_data['name'],
          'urls' => {
            'GitHub' => "http://github.com/#{user_data['login']}",
            'Blog' => user_data["blog"],
          }
        }
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data}
        })
      end
    end
  end
end
