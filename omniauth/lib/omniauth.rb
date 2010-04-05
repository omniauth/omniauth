require 'omniauth/core'

%w(password oauth basic openid).each do |s|
  begin
    require "omniauth/#{s}"
  rescue LoadError
    puts "Unable to find the files for oa-#{s}, ignored it."
  end
end