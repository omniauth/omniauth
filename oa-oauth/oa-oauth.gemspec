require 'omniauth/version'

Gem::Specification.new do |gem|
  gem.name = "oa-oauth"
  gem.version = File.open(File.dirname(__FILE__) + '/VERSION', 'r').read.trim
  gem.summary = %Q{OAuth strategies for OmniAuth.}
  gem.description = %Q{OAuth strategies for OmniAuth.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omni_auth"
  gem.authors = ["Michael Bleigh"]
  
  gem.add_dependency 'oa-core'
  gem.add_dependency 'oauth'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'json'
  
  gem.add_development_dependency "rspec", ">= 1.2.9"
end