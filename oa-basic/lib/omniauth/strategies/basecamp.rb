require 'omniauth/basic'
require 'nokogiri'

module OmniAuth
  module Strategies
    class Basecamp < HttpBasic
      def initialize(app)
        super(app, :basecamp, nil)
      end
      
      def endpoint
        "http://#{request.params['user']}:#{request.params['password']}@#{request.params['subdomain']}.basecamphq.com/me.xml"
      end
      
      def perform_authentication(endpoint)
        super(endpoint) rescue super(endpoint.sub('http','https'))
      end
      
      def auth_hash
        doc = Nokogiri::XML.parse(@response.body)
        OmniAuth::Utils.deep_merge(super, {
          'uid' => doc.xpath('person/id').text,
          'user_info' => user_info(doc),
          'credentials' => {
            'token' => doc.xpath('person/token').text
          }
        })
      end
      
      def user_info(doc)
        hash = {
          'nickname' => request.params['user'],
          'first_name' => doc.xpath('person/first-name').text,
          'last_name' => doc.xpath('person/last-name').text,
          'email' => doc.xpath('person/email-address').text,
          'image' => doc.xpath('person/avatar-url').text
        }
        
        hash['name'] = [hash['first_name'], hash['last_name']].join(' ').strip
        
        hash.delete('image') if hash['image'].include?('missing/avatar.png')
        
        hash
      end
      
      def get_credentials
        OmniAuth::Form.build('Basecamp Authentication') do
          text_field 'Subdomain', 'subdomain'
          text_field 'Username', 'user'
          password_field 'Password', 'password'
        end.to_response
      end
    end
  end
end
