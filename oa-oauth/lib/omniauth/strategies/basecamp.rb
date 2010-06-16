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
      
      BASECAMP_SUBDOMAIN_PARAMETER = 'subdomain'
      
      def initialize(app, app_id, app_secret, options = {})
        super(app, :campfire, app_id, app_secret, options)
      end
      
      protected
      
      def request_phase
        if env['REQUEST_METHOD'] == 'GET'
          ask_for_basecamp_subdomain
        else
          super(options.merge(:site => basecamp_url))
        end
      end
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get('/users/me.xml'))
      end
      
      def ask_for_basecamp_subdomain
        OmniAuth::Form.build(title) do
          text_field 'Basecamp Subdomain', BASECAMP_SUBDOMAIN_PARAMETER
        end.to_response
      end
      
      def campfire_url
        subdomain = request.params[BASECAMP_SUBDOMAIN_PARAMETER]
        'http://#{subdomain}.basecamphq.com'
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
      
      def user_info(hash)
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
