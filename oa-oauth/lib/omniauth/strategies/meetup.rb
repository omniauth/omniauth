require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # 
    # Authenticate to Meetup via OAuth and retrieve an access token for API usage
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Meetup, 'consumerkey', 'consumersecret'
    #
    class Meetup < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key, consumer_secret)
        super(app, :meetup, consumer_key, consumer_secret,
                :site => 'https://api.meetup.com',
                :request_token_path => "/oauth/request",
                :access_token_path  => "/oauth/access",
                :authorize_path    => "http://www.meetup.com/authorize/")
      end
    end
  end
end
