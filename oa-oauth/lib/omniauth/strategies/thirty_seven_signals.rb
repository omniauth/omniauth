require 'omniauth/oauth'

module OmniAuth
  module Strategies
    
    # Abstract Strategy for 37Signals OAuth2 providers.
    class ThirtySevenSignals < OAuth2
      
      SUBDOMAIN_PARAMETER = 'subdomain'
      
      def initialize(app, name, client_id, client_secret, options = {})
        super(app, name, client_id, client_secret, options)
      end
      
      protected
      
      def client
        ::OAuth2::Client.new(@client.id, @client.secret, :site => site_url)
      end
      
      def request_phase
        if subdomain
          super
        else
          ask_for_subdomain
        end
      end
      
      def callback_phase
        if subdomain
          super
        else
          ask_for_subdomain
        end
      end
      
      def ask_for_subdomain
        n = self.name.to_s.capitalize
        OmniAuth::Form.build("#{n} Subdomain Required") do
          text_field "#{n} Subdomain", ::OmniAuth::Strategies::ThirtySevenSignals::SUBDOMAIN_PARAMETER
        end.to_response
      end
      
      def subdomain
        ((request.session[:oauth] ||= {})[name.to_sym] ||= {})[:subdomain] ||= request.params[SUBDOMAIN_PARAMETER]
      end
      
      def site_url
        raise NotImplementedError.new("Subclasses must define #{site_url}")
      end
      
    end
    
  end
  
end
