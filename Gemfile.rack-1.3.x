source 'https://rubygems.org'

gem 'jruby-openssl', :platforms => :jruby
gem 'rack', '~> 1.3.0'
gem 'rake'
gem 'yard'

platforms :rbx do
 gem 'rubysl', '~> 2.0'
 gem 'psych'
 gem 'json'
 gem 'rubinius-developer_tools'
end

group :test do
  gem 'coveralls', :require => false
  gem 'rack-test'
  gem 'rspec', '>= 2.11'
  gem 'simplecov', :require => false
end

gemspec
