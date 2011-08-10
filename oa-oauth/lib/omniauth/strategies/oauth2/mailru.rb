require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Vkontakte utilizing OAuth 2.0 and retrieve
    # basic user information.
    # documentation available here:
    # http://api.mail.ru/docs/guides/oauth/sites/
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Mailru, 'API Key', 'Secret Key', :private_key => 'Private Key'
    class Mailru < OmniAuth::Strategies::OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered in Mailru]
      # @param [String] client_secret the application secret as [registered in Mailru]
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'https://connect.mail.ru/oauth/authorize',
          :token_url => 'https://connect.mail.ru/oauth/token',
        }
        @private_key  = options[:private_key]
        super(app, :mailru, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => user_data['uid'],
            'user_info' => user_info,
            'extra' => {
              'user_hash' => user_data,
            },
          }
        )
      end

      def request_phase
        options[:response_type] ||= 'code'
        super
      end

      def calculate_signature(params)
        str = params['uids'] + (params.sort.collect { |c| "#{c[0]}=#{c[1]}" }).join('') + @private_key
        Digest::MD5.hexdigest(str)
      end

      def user_data
        request_params = {
          'method' => 'users.getInfo',
          'app_id' => client_id,
          'session_key' => @access_token.token,
          'uids' => @access_token['x_mailru_vid']
        }

        request_params.merge!('sig' => calculate_signature(request_params))
        @data ||= MultiJson.decode(client.request(:get, 'http://www.appsmail.ru/platform/api', request_params))[0]
      end

      def user_info
        {
          'nickname' => user_data['nick'],
          'email' =>  user_data['email'],
          'first_name' => user_data['first_name'],
          'last_name' => user_data['last_name'],
          'name' => "#{user_data['first_name']} #{user_data['last_name']}".strip,
          'image' => @data['pic'],
          'urls' => {
            'Mailru' => user_data['link'],
          },
        }
      end
    end
  end
end
