require 'omniauth/core'

module OmniAuth
  module Strategies
    autoload :WindowsLive, 'omniauth/strategies/windows_live'
    autoload :Flickr, 'omniauth/strategies/flickr'
    autoload :Yupoo, 'omniauth/strategies/yupoo'
  end
end
