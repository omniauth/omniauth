source 'https://rubygems.org'

gem 'jruby-openssl', '~> 0.10.5', platforms: :jruby
gem 'rake', '>= 12.0'
gem 'yard', '>= 0.9.11'

group :development do
  gem 'benchmark-ips'
  gem 'kramdown'
  gem 'memory_profiler'
  gem 'pry'
end

group :test do
  gem 'coveralls_reborn', '~> 0.19.0', require: false
  gem 'rack-test'
  gem 'rspec', '~> 3.5'
  gem 'rack-freeze'
  gem 'rubocop', '~> 1.51', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov-lcov'
end

gemspec
