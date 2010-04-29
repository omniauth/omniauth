require 'json'

module OmniAuth
  module Strategies
    class GitHub < OAuth2
      def initialize(app, app_id, app_secret, options = {})
        options[:site] = 'https://github.com/'
        options[:authorize_path] = '/login/oauth/authorize'
        options[:access_token_path] = '/login/oauth/access_token'
        super(app, :github, app_id, app_secret, options)
      end
      
      def user_data
        @data ||= JSON.parse(@access_token.get('/api/v2/json/user/show'))['user']
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