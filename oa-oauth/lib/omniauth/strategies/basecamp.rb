require 'omniauth/oauth'
require 'nokogiri'

module OmniAuth
  module Strategies
    #
    # Authenticate to Basecamp utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Basecamp, 'app_id', 'app_secret'
    class Basecamp < OAuth2
      
      BASECAMP_SUBDOMAIN_PARAMETER = 'basecamp_subdomain'
      
      def initialize(app, client_id, client_secret, options = {})
        super(app, :basecamp, client_id, client_secret, options)
      end
      
      protected
      
      def client
        ::OAuth2::Client.new(@client.id, @client.secret, :site => basecamp_url)
      end
      
      def request_phase
        if subdomain
          super
        else
          ask_for_basecamp_subdomain
        end
      end
      
      def callback_phase
        if subdomain
          super
        else
          ask_for_basecamp_subdomain
        end
      end
      
      def subdomain
        ((request.session[:oauth] ||= {})[:basecamp] ||= {})[:subdomain] ||= request.params[BASECAMP_SUBDOMAIN_PARAMETER]
      end
      
      def user_data
        @data ||= Nokogiri::XML.parse(@access_token.get('/users/me.xml'))
      end
      
      def ask_for_basecamp_subdomain
        OmniAuth::Form.build('Basecamp Subdomain Required') do
          text_field 'Basecamp Subdomain', ::OmniAuth::Strategies::Basecamp::BASECAMP_SUBDOMAIN_PARAMETER
        end.to_response
      end
      
      def basecamp_url
        "https://#{subdomain}.basecamphq.com"
      end
      
      def auth_hash
        doc = user_data
        OmniAuth::Utils.deep_merge(super, {
          'uid' => doc.xpath('person/id').text,
          'user_info' => user_info(doc),
          'credentials' => {
            'token' => doc.xpath('person/token').text
          },
          'extra' => {
            'access_token' => @access_token
          }
        })
      end
      
      def user_info(doc)
        hash = {
          'first_name' => doc.xpath('person/first-name').text,
          'last_name' => doc.xpath('person/last-name').text,
          'email' => doc.xpath('person/email-address').text,
          'image' => doc.xpath('person/avatar-url').text
        }
        
        hash['name'] = [hash['first_name'], hash['last_name']].join(' ').strip
        
        hash.delete('image') if hash['image'].include?('missing/avatar.png')
        
        hash
      end
    end
  end
end
