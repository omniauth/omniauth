require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to Vkontakte utilizing OAuth 2.0 and retrieve
    # basic user information.
    # documentation available here:
    # http://api.mail.ru/docs/guides/oauth/sites/
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Vkontakte, 'API Key', 'Secret Key'
    class Mailru < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] api_key the application id as [registered in Vkontakte]
      # @param [String] secret_key the application secret as [registered in Vkontakte]
      def initialize(app, api_key = nil, secret_key = nil, options = {}, &block)
        client_options = {
          :site => 'https://connect.mail.ru',
          :authorize_path => '/oauth/authorize',
          :access_token_path => '/oauth/token'
        }
        
        options[:scope] ||= "widget"

        super(app, :mailru, api_key, secret_key, client_options, options, &block)
      end

      protected
      
      def request_phase
        options[:response_type] ||= 'code'
        super
      end      

      def user_data
        @data = {}
        #@data ||= MultiJson.decode(@access_token.get("http://www.appsmail.ru/platform/api?method=users.getInfo&app_id=#{api_key}&session_key=#{@access_token['access_token']}&sig=#{secret_key}"))[0]
        #@data ||= MultiJson.decode(@access_token.get("http://www.appsmail.ru/platform/api?method=users.getInfo"))[0]        
      end


      def user_info
        {
          #'email' => user_data['email']
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
