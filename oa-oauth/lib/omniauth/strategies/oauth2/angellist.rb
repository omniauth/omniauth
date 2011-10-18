require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to AngelList utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::AngelList, 'API Key', 'Secret Key'
    class AngelList < OmniAuth::Strategies::OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered on AngelList](http://angel.co/api/oauth/faq)
      # @param [String] client_secret the application secret as [registered on AngelList](http://bit.ly/api/oauth/faq )
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :site => 'https://api.angel.co/',
          :authorize_url => 'https://angel.co/api/oauth/authorize',
          :token_url => 'https://angel.co/api/oauth/token'
        }

        super(app, :angellist, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['id'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_data,
            }
          }
        )
      end

      def user_info
        {
          'name' => user_data['name'],
          'bio' => user_data['bio'],
          'image' => user_data['image'],
          'urls' => {
            'AngelList' => user_data['angellist_url'],
            'Website' => user_data['online_bio_url']
          },
        }
      end

      def user_data
        @data ||= begin
          @access_token.options[:mode] = :query
          @access_token.get('/1/me').parsed
        end
      end
    end
  end
end
