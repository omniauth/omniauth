require 'omniauth/openid'

module OmniAuth
  module Strategies
    class GoogleApps < OmniAuth::Strategies::OpenID
      def initialize(app, domain, store = nil, options = {})
        @domain = domain
        options[:name] ||= 'apps'
        super(app, store, options)
      end
      
      def identifier
        @domain
      end
    end
  end
end
