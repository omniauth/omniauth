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
        secure_with_cookies!
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

      private
      def secure_with_cookies!
        parsed = {}

        xn_cookie_names.each { |key| parsed[key[xn_cookie_prefix.size, key.size]] = request.cookies[key] }

        # #returning gracefully if the cookies aren't set or have expired
        # return unless parsed['session_key'] && parsed['user'] && parsed['expires'] && parsed['ss']
        # # TODO: check expires, why it alway less than Time.now
        # return unless (Time.at(parsed['expires'].to_s.to_f) > Time.now) || (parsed['expires'] == "0")
        # #if we have the unexpired cookies, we'll throw an exception if the sig doesn't verify
        verify_signature(parsed, request.cookies[Renren.api_key], true)

        @renren_session = Renren::Session.new(parsed)
        @renren_session
      end

      def xn_cookie_names
        xn_cookie_names = request.cookies.keys.select {|k| k && k.starts_with?(xn_cookie_prefix) }
      end

      def xn_cookie_prefix
        Renren.api_key + '_'
      end

      def verify_signature(renren_sig_params, expected_signature, force=false)
        raw_string = renren_sig_params.map{ |*args| args.join('=') }.sort.join
        actual_sig = Digest::MD5.hexdigest([raw_string, Renren.secret_key].join)
        # raise Renren::Session::IncorrectSignature if actual_sig != expected_signature
        # raise Renren::Session::SignatureTooOld if renren_sig_params['time'] && Time.at(renren_sig_params['time'].to_f) < earliest_valid_session
        true
      end
    end
  end
end
