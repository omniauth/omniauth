require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class ThirtySevenSignals < OmniAuth::Strategies::OAuth2
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://launchpad.37signals.com/authorization/new',
          :token_url => 'https://launchpad.37signals.com/authorization/token',
        }
        super(app, :thirty_seven_signals, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['identity']['id'],
            'user_info' => user_info,
            'extra' => {
              'accounts' => user_data['accounts'],
            }
          }
        )
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/authorization.json'))
      end

      def user_info
        {
          'email' => user_data['identity']['email_address'],
          'first_name' => user_data['identity']['first_name'],
          'last_name' => user_data['identity']['last_name'],
          'name' => [user_data['identity']['first_name'], user_data['identity']['last_name']].join(' ').strip,
        }
      end
    end
  end
end
