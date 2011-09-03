# encoding: utf-8
require File.expand_path('../lib/omniauth/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'addressable', '~> 2.2.6'
  gem.add_dependency 'net-ldap', '~> 0.2.2'
  gem.add_dependency 'nokogiri', '~> 1.5.0'
  gem.add_dependency 'oa-core', OmniAuth::Version::STRING
  gem.add_dependency 'pyu-ruby-sasl', '~> 0.0.3.1'
  gem.add_dependency 'rubyntlm', '~> 0.1.1'
  gem.add_dependency 'uuid'
  gem.add_dependency 'XMLCanonicalizer', '~> 1.0.1'
  gem.add_development_dependency 'rack-test', '~> 0.5'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rdiscount', '~> 1.6'
  gem.add_development_dependency 'rspec', '~> 2.5'
  gem.add_development_dependency 'simplecov', '~> 0.4'
  gem.add_development_dependency 'webmock', '~> 1.7'
  gem.add_development_dependency 'yard', '~> 0.7'
  gem.authors = ['James A. Rosen', 'Ping Yu', 'Michael Bleigh', 'Erik Michaels-Ober', 'Raecoo Cao']
  gem.description = %q{Enterprise strategies for OmniAuth.}
  gem.email = ['james.a.rosen@gmail.com', 'ping@intridea.com', 'michael@intridea.com', 'sferik@gmail.com', 'raecoo@intridea.com']
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'http://github.com/intridea/omniauth'
  gem.name = 'oa-enterprise'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if gem.respond_to? :required_rubygems_version=
  gem.summary = gem.description
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version = OmniAuth::Version::STRING
end
