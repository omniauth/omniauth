require "time"

module OmniAuth
  module Strategies
    class SAML
      class AuthResponse
        
        ASSERTION = "urn:oasis:names:tc:SAML:2.0:assertion"
        PROTOCOL  = "urn:oasis:names:tc:SAML:2.0:protocol"
        DSIG      = "http://www.w3.org/2000/09/xmldsig#"

        attr_accessor :options, :response, :document, :settings

        def initialize(response, options = {})
          raise ArgumentError.new("Response cannot be nil") if response.nil?
          self.options  = options
          self.response = response
          self.document = OmniAuth::Strategies::SAML::XMLSecurity::SignedDocument.new(Base64.decode64(response))
        end

        def is_valid?
          validate(soft = true)
        end

        def validate!
          validate(soft = false)
        end

        # The value of the user identifier as designated by the initialization request response
        def name_id
          @name_id ||= begin
            node = REXML::XPath.first(document, "/p:Response/a:Assertion[@ID='#{document.signed_element_id[1,document.signed_element_id.size]}']/a:Subject/a:NameID", { "p" => PROTOCOL, "a" => ASSERTION })
            node ||=  REXML::XPath.first(document, "/p:Response[@ID='#{document.signed_element_id[1,document.signed_element_id.size]}']/a:Assertion/a:Subject/a:NameID", { "p" => PROTOCOL, "a" => ASSERTION })
            node.nil? ? nil : node.text
          end
        end

        # A hash of alle the attributes with the response. Assuming there is only one value for each key
        def attributes
          @attr_statements ||= begin
            result = {}

            stmt_element = REXML::XPath.first(document, "/p:Response/a:Assertion/a:AttributeStatement", { "p" => PROTOCOL, "a" => ASSERTION })
            return {} if stmt_element.nil?

            stmt_element.elements.each do |attr_element|
              name  = attr_element.attributes["Name"]
              value = attr_element.elements.first.text

              result[name] = value
            end

            result.keys.each do |key|
              result[key.intern] = result[key]
            end

            result
          end
        end

        # When this user session should expire at latest
        def session_expires_at
          @expires_at ||= begin
            node = REXML::XPath.first(document, "/p:Response/a:Assertion/a:AuthnStatement", { "p" => PROTOCOL, "a" => ASSERTION })
            parse_time(node, "SessionNotOnOrAfter")
          end
        end

        # Conditions (if any) for the assertion to run
        def conditions
          @conditions ||= begin
            REXML::XPath.first(document, "/p:Response/a:Assertion[@ID='#{document.signed_element_id[1,document.signed_element_id.size]}']/a:Conditions", { "p" => PROTOCOL, "a" => ASSERTION })
          end
        end

        private

        def validation_error(message)
          raise OmniAuth::Strategies::SAML::ValidationError.new(message)
        end

        def validate(soft = true)
          validate_response_state(soft) &&
          validate_conditions(soft)     &&
          document.validate(get_fingerprint, soft)
        end

        def validate_response_state(soft = true)
          if response.empty?
            return soft ? false : validation_error("Blank response")
          end

          if settings.nil?
            return soft ? false : validation_error("No settings on response")
          end

          if settings.idp_cert_fingerprint.nil? && settings.idp_cert.nil?
            return soft ? false : validation_error("No fingerprint or certificate on settings")
          end

          true
        end

        def get_fingerprint
          if settings.idp_cert
            cert = OpenSSL::X509::Certificate.new(settings.idp_cert)
            Digest::SHA1.hexdigest(cert.to_der).upcase.scan(/../).join(":")
          else
            settings.idp_cert_fingerprint
          end
        end

        def validate_conditions(soft = true)
          return true if conditions.nil?
          return true if options[:skip_conditions]

          if not_before = parse_time(conditions, "NotBefore")
            if Time.now.utc < not_before
              return soft ? false : validation_error("Current time is earlier than NotBefore condition")
            end
          end

          if not_on_or_after = parse_time(conditions, "NotOnOrAfter")
            if Time.now.utc >= not_on_or_after
              return soft ? false : validation_error("Current time is on or after NotOnOrAfter condition")
            end
          end

          true
        end

        def parse_time(node, attribute)
          if node && node.attributes[attribute]
            Time.parse(node.attributes[attribute])
          end
        end
        
      end
    end
  end
end