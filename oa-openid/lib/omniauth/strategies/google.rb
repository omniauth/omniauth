require 'omniauth/openid'

module OmniAuth
  module Strategies
    class Google < OmniAuth::Strategies::OpenID
      def initialize(app, store = nil, options = {})
        options[:name] ||= 'google'
        super(app, store, options)
      end
      
      def identifier
        'https://www.google.com/accounts/o8/id'
      end
    end
  end
end
