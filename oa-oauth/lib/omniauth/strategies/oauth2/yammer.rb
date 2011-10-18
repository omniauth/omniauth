require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # OAuth 2.0 based authentication with GitHub. In order to
    # sign up for an application, you need to [register an application](http://github.com/account/applications/new)
    # and provide the proper credentials to this middleware.
    class Yammer < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :token_url => '/oauth2/access_token.json',
          :authorize_url => '/dialog/oauth',
          :site => 'https://www.yammer.com'
        }
        super(app, :yammer, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_hash['id'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_hash,
            },
          }
        )
      end

      def user_info
        user_hash = self.user_hash
        {
          'nickname' => user_hash['name'],
          'name' => user_hash['full_name'],
          'location' => user_hash['location'],
          'image' => user_hash['mugshot_url'],
          'description' => user_hash['job_title'],
          'email' => user_hash['contact']['email_addresses'][0]['address'],
          'urls' => {
            'Yammer' => user_hash['web_url'],
          },
        }
      end

      def build_access_token
        # Dance to get the real token out of the object returned by Yammer
        verifier = request.params['code']
        temp_access_token = client.auth_code.get_token(verifier, {:redirect_uri => callback_url}.merge(options))
        token = eval(temp_access_token.token)['token']
        @access_token = ::OAuth2::AccessToken.new(client, token, temp_access_token.params)
      rescue ::OAuth2::Error => e
        raise e.response.inspect
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/api/v1/users/current.json').body)
      end


    end
  end
end
