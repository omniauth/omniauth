require 'rubygems'

version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-more"
  gem.version = version
  gem.summary = %Q{Additional strategies for OmniAuth.}
  gem.description = %Q{Additional strategies for OmniAuth.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE)
  
  gem.add_dependency  'oa-core', version
  
  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
