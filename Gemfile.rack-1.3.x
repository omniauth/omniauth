source 'https://rubygems.org'

gem 'jruby-openssl', :platforms => :jruby
gem 'rack', '~> 1.3.0'
gem 'rake'
gem 'yard'

group :test do
  gem 'coveralls', :require => false
  gem 'mime-types', '~> 1.25', :platforms => [:jruby, :ruby_18]
  gem 'rack-test'
  gem 'rspec', '>= 2.11'
  gem 'simplecov', :require => false
end

platforms :rbx do
  gem 'rubinius-coverage', '~> 2.0'
  gem 'rubysl', '~> 2.0'
end

gemspec
