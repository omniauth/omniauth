require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to Vkontakte utilizing OAuth 2.0 and retrieve
    # basic user information.
    # documentation available here:
    # http://vkontakte.ru/developers.php?o=-17680044&p=Authorization&s=0
    #
    # @example Basic Usage
    #     use OmniAuth::Strategies::Vkontakte, 'API Key', 'Secret Key'
    class Vkontakte < OmniAuth::Strategies::OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered in Vkontakte]
      # @param [String] client_secret the application secret as [registered in Vkontakte]
      def initialize(app, client_id=nil, client_secret=nil, options={}, &block)
        client_options = {
          :authorize_url => 'http://api.vkontakte.ru/oauth/authorize',
          :token_url => 'https://api.vkontakte.ru/oauth/token',
        }
        super(app, :vkontakte, client_id, client_secret, client_options, options, &block)
      end

      def auth_hash
        # process user's info
        user_data
        OmniAuth::Utils.deep_merge(
          super, {
            'uid' => @data['uid'],
            'user_info' => user_info,
            'extra' => user_hash,
          }
        )
      end

      def user_data
        # http://vkontakte.ru/developers.php?o=-17680044&p=Description+of+Fields+of+the+fields+Parameter
        @fields ||= ['uid', 'first_name', 'last_name', 'nickname', 'domain', 'sex', 'bdate', 'city', 'country', 'timezone', 'photo', 'photo_big']

        # http://vkontakte.ru/developers.php?o=-1&p=getProfiles
        response = @access_token.get('https://api.vkontakte.ru/method/getProfiles',
          :params => {:uid => @access_token['user_id'], :fields => @fields.join(',')}, :parse => :json)
        @data ||= response.parsed['response'][0]

        # we need these 2 additional requests since vkontakte returns only ids of the City and Country
        # http://vkontakte.ru/developers.php?o=-17680044&p=getCities
        response = @access_token.get('https://api.vkontakte.ru/method/getCities',
          :params => {:cids => @data['city']}, :parse => :json)
        cities = response.parsed['response']
        @city ||= cities.first['name'] if cities && cities.first

        # http://vkontakte.ru/developers.php?o=-17680044&p=getCountries
        response = @access_token.get('https://api.vkontakte.ru/method/getCountries',
          :params => {:cids => @data['country']}, :parse => :json)
        countries = response.parsed['response']
        @country ||= countries.first['name'] if countries && countries.first
      end

      def request_phase
        options[:response_type] ||= 'code'
        super
      end

      def build_access_token
        token = super
        # indicates that `offline` permission was granted, no need to the token refresh
        if token.expires_in == 0
          ::OAuth2::AccessToken.new(token.client, token.token,
            token.params.reject{|k,_| [:refresh_token, :expires_in, :expires_at, :expires].include? k.to_sym}
          )
        else
          token
        end
      end

      def user_info
        {
          'first_name' => @data['first_name'],
          'last_name' => @data['last_name'],
          'name' => "#{@data['first_name']} #{@data['last_name']}".strip,
          'nickname' => @data['nickname'],
          'birth_date' => @data['bdate'],
          'image' => @data['photo'],
          'location' => "#{@country}, #{@city}",
          'urls' => {
            'Vkontakte' => "http://vkontakte.ru/#{@data['domain']}",
          },
        }
      end

      def user_hash
        {
          'user_hash' => {
            'gender' => @data['sex'],
            'timezone' => @data['timezone'],
            # 200px maximum resolution of the avatar (http://vkontakte.ru/developers.php?o=-17680044&p=Description+of+Fields+of+the+fields+Parameter)
            'photo_big' => @data['photo_big'],
          }
        }
      end
    end
  end
end
