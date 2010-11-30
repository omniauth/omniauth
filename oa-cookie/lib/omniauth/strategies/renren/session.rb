require 'digest/md5'
require 'multi_json'

module OmniAuth
  module Strategies
    class Renren
      class Session
        class IncorrectSignature < Exception; end
        class SessionExpired < Exception; end
        class OtherException < Exception; end

        attr_reader :session_key
        attr_reader :expires
        attr_reader :uid

        def initialize(cookies)
          options = extract_renren_cookies(cookies)
          @expires = options['expires'] ? Integer(options['expires']) : 0
          @session_key = options['session_key']
          @uid = options['user']
        end

        def user
          @user ||= invoke_method('users.getInfo', :uids => @uid, :format => :json).first
        end

        def infinite?
          @expires == 0
        end

        def expired?
          @expires.nil? || (!infinite? && Time.at(@expires) <= Time.now)
        end

        def secured?
          !@session_key.nil? && !expired?
        end

        def compute_sig(params)
          str = params.collect {|k,v| "#{k}=#{v}"}.sort.join("") + Renren.secret_key
          str = Digest::MD5.hexdigest(str)
        end

        def invoke_method(method, params = {})
          xn_params = {
            :method => method,
            :api_key => Renren.api_key,
            :session_key => session_key,
            :call_id => Time.now.to_i,
            :v => '1.0',
            :format => :json
          }
          xn_params.merge!(params) if params
          xn_params.merge!(:sig => compute_sig(xn_params))
          MultiJson.decode(Service.new.post(xn_params).body)
        end

        private
        def extract_renren_cookies(cookies)
          parsed = {}
          xn_cookie_names(cookies).each { |key| parsed[key[xn_cookie_prefix.size, key.size]] = cookies[key] }

          # #returning gracefully if the cookies aren't set or have expired
          # return unless parsed['session_key'] && parsed['user'] && parsed['expires'] && parsed['ss']
          # # TODO: check expires, why it alway less than Time.now
          # return unless (Time.at(parsed['expires'].to_s.to_f) > Time.now) || (parsed['expires'] == "0")
          # #if we have the unexpired cookies, we'll throw an exception if the sig doesn't verify
          verify_signature(parsed, cookies[Renren.api_key], true)
          parsed
        end

        def xn_cookie_names(cookies)
          xn_cookie_names = cookies.keys.select {|k| k && k.starts_with?(xn_cookie_prefix) }
        end

        def xn_cookie_prefix
          Renren.api_key + '_'
        end

        def verify_signature(renren_sig_params, expected_signature, force=false)
          raw_string = renren_sig_params.map{ |*args| args.join('=') }.sort.join
          actual_sig = Digest::MD5.hexdigest([raw_string, Renren.secret_key].join)
          raise Renren::Session::IncorrectSignature if actual_sig != expected_signature
          # raise Renren::Session::SignatureTooOld if renren_sig_params['time'] && Time.at(renren_sig_params['time'].to_f) < earliest_valid_session
          true
        end
      end
    end
  end
end
