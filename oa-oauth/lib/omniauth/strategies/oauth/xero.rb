require 'omniauth/oauth'

module OmniAuth
  module Strategies
    #
    # Authenticate to Xero via OAuth.
    # 
    # The Xero OAuth process is pretty straight forward and follows the typical 3-legged authentication process. 
    # 
    # For this reason we can re-use the majority of the default OmniAuth::Strategies::OAuth class and lifecycle.
    #
    class Xero < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :request_token_path => '/oauth/RequestToken',          
          :authorize_path => '/oauth/Authorize',
          :access_token_path => '/oauth/AccessToken',
          :site => 'https://api.xero.com',
        }        
        super(app, :xero, consumer_key, consumer_secret, client_options, options, &block)
      end      
    end
  end
end
