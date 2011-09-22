require 'multi_xml'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class Goodreads < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :site => 'http://www.goodreads.com',
        }
        @consumer_key = consumer_key
        super(app, :goodreads, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        hash = user_info(@access_token)

        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => hash.delete('id'),
            'user_info' => hash,
          }
        )
      end

      def user_info(access_token)
        authenticated_user = MultiXml.parse(access_token.get('/api/auth_user').body)
        id = authenticated_user['GoodreadsResponse']['user']['id'].to_i
        response_doc = MultiXml.parse(access_token.get("/user/show/#{id}.xml?key=#{@consumer_key}").body)
        user = response_doc['GoodreadsResponse']['user']

        hash = {
          'id' => id,
          'name' => user['name'],
          'user_name' => user['user_name'],
          'image_url' => user['image_url'],
          'about' => user['about'],
          'location' => user['location'],
          'website' => user['website'],
        }
      end
    end
  end
end
