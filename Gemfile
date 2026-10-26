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
  # RuboCop 1.92 needs Ruby 2.7+, so older Rubies skip the rubocop task.
  gem 'rubocop', '~> 1.92.0', :platforms => :mri if RUBY_VERSION >= '2.7'
  # Steep 2.1 needs Ruby 3.3+, so older Rubies skip the steep task.
  gem 'steep', '~> 2.1', :require => false, :platforms => :mri if RUBY_VERSION >= '3.3'
  # Mutant needs Ruby 3.3+, so older Rubies skip the mutant task. 0.17.1
  # is the first release that can test module_function methods, like
  # OmniAuth::Utils's.
  gem 'mutant', '~> 0.17.1', :platforms => :mri if RUBY_VERSION >= '3.3'
  gem 'mutant-rspec', '~> 0.17.1', :require => false, :platforms => :mri if RUBY_VERSION >= '3.3'
  # Duel requires Ruby 3.4 or later. It profiles a regression with
  # StackProf, which runs on CRuby only.
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4')
    gem 'duel', '>= 0.1.1'
    gem 'stackprof', :platforms => :mri
  end
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
