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

        def initialize(options)
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
      end
    end
  end
end
