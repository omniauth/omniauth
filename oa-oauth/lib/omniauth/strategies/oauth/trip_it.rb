require 'omniauth/oauth'

module OmniAuth
  module Strategies
    #
    # Authenticate to TripIt via OAuth and retrieve an access token for API usage
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::TripIt, 'consumerkey', 'consumersecret'
    #
    class TripIt < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/oauth/access_token',
          :authorize_url => 'https://www.tripit.com/oauth/authorize',
          :request_token_path => '/oauth/request_token',
          :site => 'https://api.tripit.com',
        }
        super(app, :tripit, consumer_key, consumer_secret, client_options, options, &block)
      end
    end
  end
end
