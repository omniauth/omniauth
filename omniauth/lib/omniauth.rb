require 'omniauth/core'

%w(password oauth basic openid).each do |s|
  require "omniauth/#{s}"
end