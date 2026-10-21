# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'hashie', '>= 3.5.2'
  spec.add_dependency 'logger'
  spec.add_dependency 'rack', '>= 2.2.8'
  spec.add_dependency 'rack-protection', '>= 2.2.0'
  spec.authors       = ['Erik Berlin', 'Michael Bleigh', 'Bobby McDonald', 'Tom Milewski']
  spec.description   = 'A generalized Rack framework for multiple-provider authentication.'
  spec.email         = ['sferik@gmail.com', 'michael@intridea.com', 'bobbymcwho@gmail.com', 'tmilewski@gmail.com']
  spec.files         = Dir['lib/**/*', 'sig/**/*.rbs', 'sig/manifest.yaml', 'CHANGELOG.md', 'LICENSE.md', 'README.md', 'SECURITY.md']
  spec.homepage      = 'https://github.com/omniauth/omniauth'
  spec.licenses      = %w[MIT]
  spec.name          = 'omniauth'
  spec.require_paths = %w[lib]
  spec.required_ruby_version = '>= 2.5'
  spec.summary       = spec.description
  spec.version       = OmniAuth::VERSION
  spec.metadata      = {
    'changelog_uri' => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'rubygems_mfa_required' => 'true'
  }
end
