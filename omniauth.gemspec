# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'hashie', ['>= 1.2', '< 4']
  spec.add_dependency 'rack', '~> 1.0'
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.authors       = ['Michael Bleigh', 'Erik Michaels-Ober', 'Tom Milewski']
  spec.description   = 'A generalized Rack framework for multiple-provider authentication.'
  spec.email         = ['michael@intridea.com', 'sferik@gmail.com', 'tmilewski@gmail.com']
  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.homepage      = 'http://github.com/intridea/omniauth'
  spec.licenses      = %w(MIT)
  spec.name          = 'omniauth'
  spec.require_paths = %w(lib)
  spec.required_rubygems_version = '>= 1.3.5'
  spec.summary       = spec.description
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.version       = OmniAuth::VERSION
end
