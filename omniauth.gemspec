# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth/version', __FILE__)

Gem::Specification.new do |gem|
  %w(oa-core oa-oauth oa-basic oa-openid oa-enterprise oa-more).each do |subgem|
    gem.add_runtime_dependency subgem, OmniAuth::Version::STRING
  end
  gem.name = 'omniauth'
  gem.version = OmniAuth::Version::STRING
  gem.summary = %q{Rack middleware for standardized multi-provider authentication.}
  gem.description = %q{OmniAuth is an authentication framework that that separates the concept of authentiation from the concept of identity, providing simple hooks for any application to have one or multiple authentication providers for a user.}
  gem.email = ['michael@intridea.com', 'sferik@gmail.com']
  gem.homepage = 'http://github.com/intridea/omniauth'
  gem.authors = ['Michael Bleigh', 'Erik Michaels-Ober']
  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if gem.respond_to? :required_rubygems_version=
end
