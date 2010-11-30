require 'omniauth/cookie'

module OmniAuth
  module Strategies
    class Renren
      include OmniAuth::Strategy
      autoload :Session, 'omniauth/strategies/renren/session'
      autoload :Service, 'omniauth/strategies/renren/service'
      autoload :Helper, 'omniauth/strategies/renren/helper'

      class << self
        def api_key
          @@api_key
        end

        def secret_key
          @@secret_key
        end
      end

      def initialize(app, api_key, secret_key, options = {})
        @@api_key = api_key
        @@secret_key = secret_key

        super(app, :renren, options)
      end

      def request_phase
        @response.finish
      end

      def callback_phase
        @renren_session = Renren::Session.new(request.cookies)
        super
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @renren_session.uid,
          'user_info' => @renren_session.user,
          'extra' => {
            'renren_session' => @renren_session
          }
        })
      end
    end
  end
end
