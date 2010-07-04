require 'rubygems'

version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-corporate"
  gem.version = version
  gem.summary = %Q{Corporate strategies for OmniAuth.}
  gem.description = %Q{Corporate strategies for OmniAuth.}
  gem.email = "james.a.rosen@gmail.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["James A. Rosen"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.rdoc CHANGELOG.rdoc)
  
  gem.add_dependency  'oa-core',    version
  gem.add_dependency  'rack',       '~> 1.1.0'
  gem.add_dependency  'nokogiri',   '~> 1.4.2'
  
  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
