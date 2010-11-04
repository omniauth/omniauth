require 'omniauth/openid'

module OmniAuth
  module Strategies
    class GoogleOpenID < OmniAuth::Strategies::OpenID

      # OmniAuth::Strategies::GoogleOpenID helps you
      # to use plain open_id and google open_id both in the same application
      #
      #     use OmniAuth::Builder do
      #       provider :google_open_id
      #       provider :open_id, OpenID::Store::Filesystem.new('/tmp')
      #     end
      #

      def initialize(app, store = nil, options = {})
        options[:name]||='google_open_id'
        super(app, store, options)
      end

      
      def identifier
        'https://www.google.com/accounts/o8/id'
      end

    end
  end
end
