# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'hashie', ['>= 1.2', '< 3']
  spec.add_dependency 'rack'
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.authors       = ['Michael Bleigh', 'Erik Michaels-Ober']
  spec.cert_chain    = %w(certs/sferik.pem)
  spec.description   = %q{A generalized Rack framework for multiple-provider authentication.}
  spec.email         = ['michael@intridea.com', 'sferik@gmail.com']
  spec.files         = %w(.yardopts LICENSE.md README.md Rakefile omniauth.gemspec)
  spec.files        += Dir.glob("lib/**/*.rb")
  spec.files        += Dir.glob("spec/**/*")
  spec.homepage      = 'http://github.com/intridea/omniauth'
  spec.licenses      = ['MIT']
  spec.name          = 'omniauth'
  spec.require_paths = ['lib']
  spec.required_rubygems_version = '>= 1.3.6'
  spec.signing_key   = File.expand_path("~/.gem/private_key.pem") if $0 =~ /gem\z/
  spec.summary       = spec.description
  spec.test_files    = Dir.glob("spec/**/*")
  spec.version       = OmniAuth::VERSION
end
