require 'rubygems'

version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-identity"
  gem.version = version
  gem.summary = %Q{Login and password authentication for OmniAuth.}
  gem.description = %Q{Login and password authentication for OmniAuth.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE)
  
  gem.add_dependency  'oa-core', version
  gem.add_dependency  'activesupport', '~> 3.0.0'
  gem.add_dependency  'uuid'

  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
