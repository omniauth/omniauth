require 'rack/openid'
require 'omniauth/openid'
require 'oauth'

module OmniAuth
  module Strategies
    # OmniAuth strategy for connecting via OpenID. This allows for connection
    # to a wide variety of sites, some of which are listed [on the OpenID website](http://openid.net/get-an-openid/).
    class GoogleHybrid < OmniAuth::Strategies::OpenID

      protected

      def dummy_app
        lambda{|env| [401, {"WWW-Authenticate" => Rack::OpenID.build_header(
          :identifier => identifier,
          :return_to => callback_url,
          :required => @options[:required],
          :optional => @options[:optional],
          :"oauth[consumer]" => @options[:consumer_key],
          :"oauth[scope]" => @options[:scope], 
          :method => 'post'
        )}, []]}
      end

      def auth_hash
        oauth_response = ::OpenID::OAuth::Response.from_success_response(@openid_response)

        consumer = ::OAuth::Consumer.new(
          @options[:consumer_key],
          @options[:consumer_secret],
          :site => 'https://www.google.com',
          :access_token_path  => '/accounts/OAuthGetAccessToken'
        )
        request_token = ::OAuth::RequestToken.new(
          consumer,
          oauth_response.request_token,
          "" # OAuth request token secret is also blank in OpenID/OAuth Hybrid
        )
        @access_token = request_token.get_access_token
        
        OmniAuth::Utils.deep_merge(super(), {
          'uid' => @openid_response.display_identifier,
          'user_info' => user_info(@openid_response),
          'scope' => @options[:scope], 
          'token' => @access_token.token,
          'secret' => @access_token.secret
        })
      end
    end
  end
end

