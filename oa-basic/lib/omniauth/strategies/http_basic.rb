require 'restclient'

module OmniAuth
  module Strategies
    class HttpBasic
      include OmniAuth::Strategy
      
      def initialize(app, name, endpoint, headers = {})
        super
        @endpoint = endpoint
        @request_headers = headers
      end
      
      attr_reader :endpoint, :request_headers
      
      def request_phase
        @response = RestClient.get(endpoint, request_headers)
        request.POST['auth'] = auth_hash
        @env['REQUEST_METHOD'] = 'GET'
        @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix}/#{name}/callback"
        
        @app.call(@env)
      rescue RestClient::Request::Unauthorized
        fail!(:invalid_credentials)
      end
      
      def callback_phase
        @app.call(env)
      end
    end
  end
end
    