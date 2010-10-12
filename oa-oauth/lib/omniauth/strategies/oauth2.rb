require 'cgi'
require 'uri'
require 'oauth2'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class OAuth2
      include OmniAuth::Strategy
      
      attr_accessor :options, :client
      
      class CallbackError < StandardError
        attr_accessor :error, :error_reason, :error_uri
        
        def initialize(error, error_reason=nil, error_uri=nil)
          self.error = error
          self.error_reason = error_reason
          self.error_uri = error_uri
        end
      end
      
      def initialize(app, name, client_id, client_secret, options = {})
        super(app, name)
        self.options = options
        self.client = ::OAuth2::Client.new(client_id, client_secret, options)
      end
      
      protected
        
      def request_phase
        redirect client.web_server.authorize_url({:redirect_uri => callback_url}.merge(options))
      end
      
      def callback_phase
        if request.params['error']
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        end
        
        verifier = request.params['code']
        @access_token = client.web_server.get_access_token(verifier, :redirect_uri => callback_url)
        super
      rescue ::OAuth2::HTTPError, ::OAuth2::AccessDenied, CallbackError => e
        fail!(:invalid_credentials, e)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'credentials' => {
            'token' => @access_token.token
          }
        })
      end
    end
  end
end
