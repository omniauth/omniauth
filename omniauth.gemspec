# encoding: utf-8
require File.expand_path('../lib/omniauth/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'omniauth'
  spec.description = %q{A generalized Rack framework for multiple-provider authentication.}
  spec.authors = ['Michael Bleigh', 'Erik Michaels-Ober']
  spec.email = ['michael@intridea.com', 'sferik@gmail.com']

  spec.add_runtime_dependency 'rack'
  spec.add_runtime_dependency 'hashie', '~> 1.2'

  spec.add_development_dependency 'kramdown'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 2.8'
  spec.add_development_dependency 'yard'

  spec.version = OmniAuth::VERSION
  spec.files = `git ls-files`.split("\n")
  spec.homepage = 'http://github.com/intridea/omniauth'
  spec.licenses = ['MIT']
  spec.require_paths = ['lib']
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  spec.summary = spec.description
  spec.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
end
