# to be evaluated within the context of a Gemspec or a Gemfile

# It's ridiculous that Bundler can't sync up with .gemspec files for
# development dependencies. Until it can, make sure to keep these
# two blocks parallel.
if Object.const_defined?(:Bundler) && Bundler.const_defined?(:Dsl) && self.kind_of?(Bundler::Dsl)
  group :development do
    gem 'rack'
    gem 'rake'
    gem 'mg',        '~> 0.0.8'
    gem 'rspec',     '~> 2.0.0'
    gem 'webmock',   '~> 1.3.4'
    gem 'rack-test', '~> 0.5.4'
    gem 'json',      '~> 1.4.3' # multi_json implementation
  end  
else #gemspec
  gem.add_development_dependency  'rake'
  gem.add_development_dependency  'mg',         '~> 0.0.8'
  gem.add_development_dependency  'rspec',      '~> 1.3.0'
  gem.add_development_dependency  'webmock',    '~> 1.3.4'
  gem.add_development_dependency  'rack-test',  '~> 0.5.4'
  gem.add_development_dependency  'json',       '~> 1.4.3' # multi_json implementation
end
