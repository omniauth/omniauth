source 'https://rubygems.org'

gem 'jruby-openssl', :platforms => :jruby
gem 'rack', '~> 1.3.0'
gem 'rake'
gem 'yard'

group :test do
  gem 'coveralls', :require => false
  gem 'json', '>= 1.8.1', :platforms => [:jruby, :rbx, :ruby_18, :ruby_19]
  gem 'mime-types', '~> 1.25', :platforms => [:jruby, :ruby_18]
  gem 'rack-test'
  gem 'rest-client', '~> 1.6.0', :platforms => [:jruby, :ruby_18]
  gem 'rspec', '>= 2.14'
  gem 'rubocop', '>= 0.23', :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem 'simplecov', :require => false
end

platforms :rbx do
  gem 'racc'
  gem 'rubinius-coverage', '~> 2.0'
  gem 'rubysl', '~> 2.0'
end

gemspec
