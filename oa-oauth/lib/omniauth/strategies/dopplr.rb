require 'omniauth/oauth'

module OmniAuth
  module Strategies
    #
    # Authenticate to Dopplr via OAuth and retrieve an access token for API usage
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Dopplr, 'consumerkey', 'consumersecret'
    #
    class Dopplr < OmniAuth::Strategies::OAuth
      # Initialize the Dopplr strategy.
      #
      # @option options [Hash, {}] :client_options Options to be passed directly to the OAuth Consumer
      def initialize(app, consumer_key, consumer_secret, options = {})
        client_options = {
          :site => 'https://www.dopplr.com',
          :request_token_path => "/oauth/request_token",
          :access_token_path  => "/oauth/access_token",
          :authorize_path    => "/oauth/authorize"
        }
        
        super(app, :dopplr, consumer_key, consumer_secret, client_options, options)
      end     
    end
  end
end
