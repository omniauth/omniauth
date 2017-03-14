require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies

    # Omniauth strategy for using 3-legged oauth and mendeley.com

    class Mendeley < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, &block)
        client_options = {
          :site => 'https://api.mendeley.com',
          :request_token_path => "https://api.mendeley.com/oauth/request_token/",
          :access_token_path => "https://api.mendeley.com/oauth/access_token/",
          :authorize_url => "https://api.mendeley.com/oauth/authorize/",
          :http_method => :get,
          :scheme => :query_string
        }

        super(app, :mendeley, consumer_key, consumer_secret, client_options, &block)
      end

      def callback_phase
        session['oauth'][name.to_s]['callback_confirmed'] = true
        super
      end

    end
  end
end