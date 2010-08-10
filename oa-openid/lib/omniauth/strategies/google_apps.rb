require 'omniauth/openid'

module OmniAuth
  module Strategies
    class GoogleApps < OmniAuth::Strategies::OpenID
      def initialize(app, store = nil, options = {})
        options[:name] ||= 'google_apps'
        super(app, store, options)
      end
      
      def identifier
        options[:domain] || request['domain']
      end
    end
  end
end
