source 'https://rubygems.org'

gem 'jruby-openssl', '~> 0.10.5', :platforms => :jruby
gem 'rake', '~> 13.4'
gem 'yard', '>= 0.9.11'

# CI sets RACK_VERSION (e.g. "~> 2.2") to test against an older Rack.
gem 'rack', ENV['RACK_VERSION'] if ENV['RACK_VERSION']
gem 'rack-session'

group :development do
  gem 'benchmark-ips'
  gem 'kramdown'
  gem 'memory_profiler'
  gem 'pry'
end

group :test do
  gem 'cgi'
  gem 'rack-test'
  gem 'rspec', '~> 3.5'
  if RUBY_VERSION >= '3.2'
    gem 'simplecov', '>= 1', :require => false
    gem 'simplecov-lcov'
  end
end

gemspec
