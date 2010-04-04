require 'rack/openid'

module OmniAuth
  module Strategies
    class OpenID
      include OmniAuth::Strategy
      
      def initialize(app, store = nil, options = {})
        super(app, :open_id)
        @options = options
        @options[:required] ||= %w(email fullname)
        @options[:optional] ||= %w(nickname dob gender postcode country language timezone)
        @store = store
      end
      
      def dummy_app
        lambda{|env| [401, {"WWW-Authenticate" => Rack::OpenID.build_header(
          :identifier => request[:identifier],
          :return_to => request.url + '/callback',
          :required => @options[:required],
          :optional => @options[:optional]
        )}, []]}
      end
      
      def request_phase
        return fail!(:missing_information) unless request[:identifier]
        openid = Rack::OpenID.new(dummy_app, @store)
        openid.call(env)
      end
      
      def callback_phase
        openid = Rack::OpenID.new(lambda{|env| [200,{},[]]}, @store)
        openid.call(env)
        resp = env.delete('rack.openid.response')
        
        case resp.status
        when :failure
          fail!(:invalid_credentials)
        when :success
          request['auth'] = auth_hash(resp)
          @app.call(env)
        end
      end
      
      def auth_hash(response)
        {
          'uid' => response.display_identifier,
          'user_info' => user_info(response.display_identifier, ::OpenID::SReg::Response.from_success_response(response))
        }
      end
      
      def user_info(identifier, sreg)
        {
          'email' => sreg['email'],
          'name' => sreg['fullname'],
          'location' => sreg['postcode'],
          'nickname' => sreg['nickname'],
          'urls' => {'Profile' => identifier}
        }.reject{|k,v| v.nil? || v == ''}
      end
    end
  end
end