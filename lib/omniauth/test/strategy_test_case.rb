require 'rack'
require 'omniauth/test'

module OmniAuth
  module Test
    # Support for testing OmniAuth strategies.
    #
    # @example Usage
    #   class MyStrategyTest < Test::Unit::TestCase
    #     include OmniAuth::Test::StrategyTestCase
    #     def strategy
    #       # return the parameters to a Rack::Builder map call:
    #       [MyStrategy, :some, :configuration, :options => 'here']
    #     end
    #     setup do
    #       post '/auth/my_strategy/callback', :user => { 'name' => 'Dylan', 'id' => '445' }
    #     end
    #   end
    module StrategyTestCase
      def app
        resp = app_response
        builder = Rack::Builder.new
        builder.use(OmniAuth::Test::PhonySession)
        builder.use(*strategy)
        # @type var endpoint: ^(Rack::env) -> Rack::response
        endpoint = lambda { |env| [404, {'Content-Type' => 'text/plain'}, [resp || env.key?('omniauth.auth').to_s]] }
        builder.run(endpoint)
        builder.to_app
      end

      def app_response
        nil
      end

      def session
        last_request.env['rack.session']
      end

      def strategy
        error = NotImplementedError.new('Including specs must define #strategy')
        raise(error)
      end
    end
  end
end
