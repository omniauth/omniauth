require 'omniauth/core'

%w(password oauth basic openid facebook).each do |s|
  require "omniauth/#{s}"
end