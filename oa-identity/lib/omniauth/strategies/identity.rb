require 'omniauth/identity'

module OmniAuth
  module Strategies
    class Identity
      include OmniAuth::Strategy

      def initialize(app, options = {})
        super(app, :identity, options) 
      end

      def request_phase
        OmniAuth::Form.build(options[:title] || 'Identify Yourself') do
          text_field 'Screen Name', 'nickname'
          password_field 'Password', 'password'
        end.to_response
      end

      def callback_phase
      end
    end
  end
end
