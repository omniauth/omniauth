require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to AngelList utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::AngelList, 'API Key', 'Secret Key'
    class Dailymotion < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :site => 'https://api.dailymotion.com',
          :authorize_url => '/oauth/authorize',
          :token_url => '/oauth/token'
        }

        super(app, :dailymotion, client_id, client_secret, client_options, options, &block)
      end
    end
  end
end
