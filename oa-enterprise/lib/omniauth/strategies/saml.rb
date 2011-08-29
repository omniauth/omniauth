require 'omniauth/enterprise'

module OmniAuth
  module Strategies
    class SAML
      include OmniAuth::Strategy
      autoload :AuthRequest,      'omniauth/strategies/saml/auth_request'
      autoload :AuthResponse,     'omniauth/strategies/saml/auth_response'
      autoload :ValidationError,  'omniauth/strategies/saml/validation_error'
      autoload :XMLSecurity,      'omniauth/strategies/saml/xml_security'
      
      @@settings = {}
      
      def initialize(app, options={})
        super(app, :saml)
        @@settings = {
          :assertion_consumer_service_url => options[:assertion_consumer_service_url],
          :issuer                         => options[:issuer],
          :idp_sso_target_url             => options[:idp_sso_target_url],
          :idp_cert_fingerprint           => options[:idp_cert_fingerprint],
          :name_identifier_format         => options[:name_identifier_format] || "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
        }
      end
          
      def request_phase
        request = OmniAuth::Strategies::SAML::AuthRequest.new
        redirect(request.create(@@settings))
      end
      
      def callback_phase
        begin
          response = OmniAuth::Strategies::SAML::AuthResponse.new(request.params['SAMLResponse'])
          response.settings = @@settings
          @name_id  = response.name_id
          return fail!(:invalid_ticket, 'Invalid SAML Ticket') if @name_id.nil? || @name_id.empty?
          super
        rescue ArgumentError => e
          fail!(:invalid_ticket, 'Invalid SAML Response')
        end        
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @name_id
        })
      end  
            
    end
  end
end
