require 'omniauth/core'

module OmniAuth
  module Strategies
    autoload :Draugiem,    'omniauth/strategies/draugiem'
    autoload :Ign,         'omniauth/strategies/ign'
    autoload :LastFm,      'omniauth/strategies/last_fm'
    autoload :WindowsLive, 'omniauth/strategies/windows_live'
    autoload :Yupoo,       'omniauth/strategies/yupoo'
  end
end
