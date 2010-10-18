require 'rubygems'

version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-enterprise"
  gem.version = version
  gem.summary = %Q{Enterprise strategies for OmniAuth.}
  gem.description = %Q{Enterprise strategies for OmniAuth.}
  gem.email = "james.a.rosen@gmail.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["James A. Rosen", "Ping Yu"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.rdoc CHANGELOG.rdoc)
  
  gem.add_dependency  'oa-core',    version
  gem.add_dependency  'nokogiri',   '~> 1.4.2'
  gem.add_dependency  'net-ldap',   '~> 0.1.1'
  gem.add_dependency  'rubyntlm',   '~> 0.1.1'
  gem.add_dependency  'pyu-ruby-sasl',  '~>0.0.3.1'
  
  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
