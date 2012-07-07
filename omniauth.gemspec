# encoding: utf-8
require File.expand_path('../lib/omniauth/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'omniauth'
  gem.description = %q{A generalized Rack framework for multiple-provider authentication.}
  gem.authors = ['Michael Bleigh', 'Erik Michaels-Ober']
  gem.email = ['michael@intridea.com', 'sferik@gmail.com']

  gem.add_runtime_dependency 'rack'
  gem.add_runtime_dependency 'hashie', '~> 1.2'

  gem.add_development_dependency 'maruku'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.8'
  gem.add_development_dependency 'yard'

  gem.version = OmniAuth::VERSION
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'http://github.com/intridea/omniauth'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if gem.respond_to? :required_rubygems_version=
  gem.summary = gem.description
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
end
