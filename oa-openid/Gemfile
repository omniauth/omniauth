require File.expand_path('../lib/omniauth/version', __FILE__)

source 'http://rubygems.org'

gem 'oa-core', OmniAuth::Version::STRING, :path => '../oa-core'
gem 'oa-oauth', OmniAuth::Version::STRING, :path => '../oa-oauth'

platforms :jruby do
  gem 'jruby-openssl', '~> 0.7'
end

gemspec
