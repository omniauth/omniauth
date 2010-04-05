require 'digest/sha1'
module OmniAuth
  module Strategies
    class Password
      include OmniAuth::Strategy
      
      def initialize(app, secret = 'changethisappsecret', options = {})
        @options = options
        @options[:identifier_key] ||= 'nickname'
        @secret = secret
        super(app, :password)
      end

      attr_reader :secret
      
      def request_phase
        return fail!(:missing_information) unless request[:identifier] && request[:password]
        return fail!(:password_mismatch) if request[:password_confirmation] && request[:password_confirmation] != '' && request[:password] != request[:password_confirmation]
        
        env['REQUEST_METHOD'] = 'GET'
        env['PATH_INFO'] = request.path + '/callback'
        request['auth'] = auth_hash(encrypt(request[:identifier], request[:password]))
        @app.call(env)
      end
      
      def auth_hash(crypted_password)
        OmniAuth::Utils.deep_merge(super(), {
          'uid' => crypted_password,
          'user_info' => {
            @options[:identifier_key] => request[:identifier]
          }
        })
      end
      
      def callback_phase
        @app.call(env)
      end
      
      def encrypt(identifier, password)
        Digest::SHA1.hexdigest([identifier, password, secret].join('::'))
      end
    end
  end
end