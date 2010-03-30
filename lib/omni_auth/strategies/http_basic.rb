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
        resp = RestClient.get(endpoint, request_headers)
      rescue RestClient::Request::Unauthorized
        fail!(:invalid_credentials)
      end
      
      def callback_phase
        
      end
    end
  end
end
    