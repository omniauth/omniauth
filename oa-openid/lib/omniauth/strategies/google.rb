require 'omniauth/openid'

module OmniAuth
  module Strategies
    class Google < OmniAuth::Strategies::OpenID
      def identifier; 'https://www.google.com/accounts/o8/id' end
    end
  end
end
