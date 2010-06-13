require 'omniauth/core'

module OmniAuth
  module Strategies
    autoload :OpenID, 'omniauth/strategies/open_id'
    autoload :Google, 'omniauth/strategies/google'
  end
end
