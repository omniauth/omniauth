version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-core"
  gem.version = version
  gem.summary = %Q{HTTP Basic strategies for OmniAuth.}
  gem.description = %Q{HTTP Basic strategies for OmniAuth.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(LICENSE.rdoc CHANGELOG.rdoc)
  
  gem.add_dependency  'rack', '~> 1.1.0'
  
  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
