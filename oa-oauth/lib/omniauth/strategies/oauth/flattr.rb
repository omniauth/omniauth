require 'omniauth/oauth'
require 'multi_xml'

module OmniAuth
  module Strategies
    # Authenticate to Flattr via OAuth and retrieve basic user information.
    # Usage:
    #    use OmniAuth::Strategies::Flattr, 'consumerkey', 'consumersecret'
    class Flattr < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :site => 'https://api.flattr.com'
        }
        options[:authorize_params] = {:access_scope => "read,publish,click,extendedread"}
        super(app, :flattr, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        ui = user_info
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['id'],
          'user_info' => ui,
          'extra' => {'user_hash' => user_hash}
        })
      end

      # user info according to schema
      def user_info
        {
          'uid'        => user_hash['id'],
          'nickname'   => user_hash['username'],
          'first_name' => user_hash['firstname'],
          'last_name'  => user_hash['lastname'],
          'name'       => [user_hash['firstname'],user_hash['lastname']].reject{ |n| n.nil? || n.empty? }.join(' '),
          'email'      => user_hash['email'],
          'language'   => user_hash['language']
        }
      end

      # info as supplied by Flattr user summary
      # response: {"flattr"=>{"version"=>"0.5", "user"=>{"id"=>"82597", "username"=>"foo", "firstname"=>"Foo", "lastname"=>"Bar", "email"=>"foo@bar.com", "city"=>"", "country"=>"", "gravatar"=>"", "url"=>"", "description"=>"", "thingcount"=>"1", "language"=>"en_GB"}}}
      def user_hash
        @user_hash ||= MultiXml.parse(@access_token.get('/rest/0.5/user/me').body)["flattr"]["user"]
      end
    end
  end
end
