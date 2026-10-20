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
  # Mutant needs Ruby 3.3+, so older Rubies skip the mutant task. Until a
  # release includes https://github.com/mbj/mutant/pull/1679, use the
  # commit that merged it, so mutant can test OmniAuth::Utils's
  # module_function methods.
  if RUBY_VERSION >= '3.3'
    git 'https://github.com/mbj/mutant.git', :ref => '25390f3c255e4cfb04177a8fd6c91ac6c5b83749', :glob => 'ruby/*.gemspec' do
      gem 'mutant', :platforms => :mri
      gem 'mutant-rspec', :require => false, :platforms => :mri
    end
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
