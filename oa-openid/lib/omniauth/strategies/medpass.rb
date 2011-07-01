require 'omniauth/openid'

module OmniAuth
  module Strategies
    class Medpass < OmniAuth::Strategies::OpenID
      def initialize(app, store = nil, options = {}, &block)
        options[:name] ||= 'medpass'
        super(app, store, options, &block)
      end

      def get_identifier
        OmniAuth::Form.build(:title => 'Logowanie przez Medpass.pl') do
          label_field('Twoj login w medpass.pl', 'login')
          input_field('login', 'login')
        end.to_response
      end

      def identifier
        return request['login'] + '.medpass.pl' if request['login']
        options[:login] || request['login']
      end      
      
    end
  end
end
