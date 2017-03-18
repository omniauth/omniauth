module OmniAuth
  module Strategies
    class Yahoo < OmniAuth::Strategies::OAuth
      unloadable
      def initialize(app, consumer_key, consumer_secret)
        super(app, :yahoo, consumer_key, consumer_secret,
              :site               => "https://api.login.yahoo.com",
              :request_token_path => "/oauth/v2/get_request_token",
              :authorize_path     => "/oauth/v2/request_auth",
              :access_token_path  => "/oauth/v2/get_token"
        )
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @access_token.params[:xoauth_yahoo_guid],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash
        profile = user_hash['profile'] || {}
        {
          'nickname'    => profile['givenName'],
          'name'        => "%s %s" % [profile['givenName'], profile['familyName']],
          'location'    => profile['location'],
          'image'       => (profile['image'] || {})['imageUrl'],
          'description' => nil,
          'urls'        => {'Profile' => profile['uri']}
        }
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get("http://social.yahooapis.com/v1/user/#{@access_token.params[:xoauth_yahoo_guid]}/profile?format=json").body)
      end
    end
  end
end