require 'rubygems'

version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-oauth"
  gem.version = version
  gem.summary = %Q{OAuth strategies for OmniAuth.}
  gem.description = %Q{OAuth strategies for OmniAuth.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE)
  
  gem.add_dependency  'oa-core',    version
  gem.add_dependency  'multi_json', '~> 0.0.2'
  gem.add_dependency  'nokogiri',   '~> 1.4.2'
  gem.add_dependency  'oauth',      '~> 0.4.0'
  gem.add_dependency  'faraday',    '~> 0.6.1'
  gem.add_dependency  'oauth2',     '~> 0.3.0'
  
  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
