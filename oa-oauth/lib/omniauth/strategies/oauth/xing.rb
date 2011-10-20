require 'json'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class Xing < OmniAuth::Strategies::OAuth

      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :access_token_path => '/v1/access_token',
          :authorize_path => '/v1/authorize',
          :request_token_path => '/v1/request_token/',
          :site => 'https://api.xing.com'
        }
        super(app, :xing, consumer_key, consumer_secret, client_options, options, &block)
      end

      def callback_phase
        session['oauth'][name.to_s]['callback_confirmed'] = true
        super
      end

      def auth_hash
        hash = user_hash(@access_token)

        OmniAuth::Utils.deep_merge(super,
          {
            'uid' => @access_token.params[:user_id],
            'user_info' => hash,
          }
        )
      end

      def user_hash(access_token)
        person = JSON.parse( access_token.get('/v1/users/me').body )["users"].first

        hash = {
          'id'          => person['id'],
          'first_name'  => person['first_name'],
          'last_name'   => person['last_name'],
          'image'       => person["photo_urls"]["large"],
          'email'       => person["active_email"],
        }
      end

    end
  end
end