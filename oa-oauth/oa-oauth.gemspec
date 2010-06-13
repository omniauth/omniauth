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
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.rdoc CHANGELOG.rdoc)
  
  gem.add_dependency  'oa-core',  version
  gem.add_dependency  'rack',     '~> 1.1.0'
  gem.add_dependency  'json',     '~> 1.4.3'
  gem.add_dependency  'nokogiri', '~> 1.4.2'
  gem.add_dependency  'oauth',    '~> 0.4.0'
  gem.add_dependency  'oauth2',   '~> 0.0.8'
  
  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
