source 'https://rubygems.org'

gem 'jruby-openssl', :platforms => :jruby
gem 'rack', '~> 1.3.0'
gem 'rake'
gem 'yard'

group :test do
  gem 'rack-test'
  gem 'rspec', '>= 2.11'
  gem 'simplecov'
end

gemspec
