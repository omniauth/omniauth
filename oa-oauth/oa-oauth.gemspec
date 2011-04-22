# -*- encoding: utf-8 -*-
require File.expand_path('../../omniauth/lib/omniauth/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency  'oa-core', Omniauth::VERSION.dup
  gem.add_dependency  'multi_json', '>= 0.0.5'
  gem.add_dependency  'nokogiri', '~> 1.4.2'
  gem.add_dependency  'oauth', '~> 0.4.0'
  gem.add_dependency  'faraday', '~> 0.6.1'
  gem.add_dependency  'oauth2', '~> 0.4.1'
  gem.add_development_dependency 'evernote', '~> 0.9'
  gem.add_development_dependency 'rack-test', '~> 0.5'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.5'
  gem.add_development_dependency 'webmock', '~> 1.6'
  gem.add_development_dependency 'yard', '~> 0.6'
  gem.name = 'oa-oauth'
  gem.version = Omniauth::VERSION.dup
  gem.summary = %q{OAuth strategies for OmniAuth.}
  gem.description = %q{OAuth strategies for OmniAuth.}
  gem.email = ['michael@intridea.com', 'sferik@gmail.com']
  gem.homepage = 'http://github.com/intridea/omniauth'
  gem.authors = ['Michael Bleigh', 'Erik Michaels-Ober']
  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if gem.respond_to? :required_rubygems_version=

end
