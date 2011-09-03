require 'omniauth/core'

module OmniAuth
  module Strategies
    autoload :Draugiem,    'omniauth/strategies/draugiem'
    autoload :Flickr, 'omniauth/strategies/flickr'
    autoload :HttpBasic, 'omniauth/strategies/http_basic'
    autoload :Ign,         'omniauth/strategies/ign'
    autoload :LastFm,      'omniauth/strategies/last_fm'
    autoload :WindowsLive, 'omniauth/strategies/windows_live'
  end
end
