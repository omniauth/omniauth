source "http://rubygems.org"

gem 'rack',             '~> 1.1.0'

group :oa_basic, :oa_oauth do
  gem 'json',             '~> 1.4.3'
  gem 'nokogiri',         '~> 1.4.2'
end

group :oa_basic do
  gem 'rest-client',      '~> 1.5.1', :require => 'restclient'
end

group :oa_oauth do
  gem 'oauth',            '~> 0.4.0'
  gem 'oauth2',           '~> 0.0.8'
end

group :oa_openid do
  gem 'rack-openid',      '~> 1.0.3', :require => 'rack/openid'
end

group :development, :test do
  gem 'rake'
end

group :development do
  gem 'mg',             '~> 0.0.8'
  gem 'term-ansicolor',             :require => 'term/ansicolor'
end

group :test do
  gem 'rspec',          '~> 1.3.0', :require => 'spec'
  gem 'webmock',        '~> 1.2.2'
end