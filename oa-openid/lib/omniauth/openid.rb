require 'omniauth/core'

module OmniAuth
  module Strategies
    autoload :OpenID, 'omniauth/strategies/open_id'
    autoload :GoogleApps, 'omniauth/strategies/google_apps'
    autoload :Google, 'omniauth/strategies/google'
  end
end
