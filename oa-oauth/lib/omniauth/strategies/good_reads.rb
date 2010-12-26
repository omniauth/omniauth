require 'omniauth/oauth'
require 'nokogiri'
require 'open-uri'

module OmniAuth
  module Strategies
    # 
    # Authenticate to GoodReads via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::GoodReads, 'api_key', 'api_secret'
    #
    class GoodReads < OmniAuth::Strategies::OAuth
      def initialize(app, api_key = nil, api_secret = nil, options = {}, &block)
        client_options = {
          :site => 'http://www.goodreads.com',
          :request_token_path => "/oauth/request_token",
          :access_token_path  => "/oauth/access_token",
          :authorize_path    => "/oauth/authorize"
        }        

        super(app, :goodreads, api_key, api_secret, client_options, options)
      end

      def auth_hash
        hash = user_hash(@access_token)
        
        OmniAuth::Utils.deep_merge(super, {
          'uid' => hash.delete('id'),
          'user_info' => hash
        })
      end
      
      # info as supplied by GoodReads
      def user_hash(access_token)        
        parsed_document = Nokogiri::XML::Document.parse(@access_token.get('/api/auth_user').body)
        user_id  = parsed_document.xpath('//user[@id]')[0].attr('id')
        user_key = parsed_document.xpath('//key')[0].text

        user_info = Nokogiri::XML::Document.parse(open("http://www.goodreads.com/user/show/#{user_id}.xml?key=#{user_key}").read)

        hash = {
          'id' => user_info.xpath('//id').first.text,
          'name' => user_info.xpath('//name').first.text,
          'nickname' => user_info.xpath('//user_name').first.text,
          'location' => user_info.xpath('//location').first.text,
          'description' => user_info.xpath('//about').first.text,
          'image' => user_info.xpath('//small_image_url').first.text,
        }
        
        hash['urls'] = Hash.new
        hash['urls']['PublicProfile'] = user_info.xpath('//link').first.text        
        hash['urls']['Website'] = user_info.xpath('//website').first.text        
        hash
      end

    end
  end
end