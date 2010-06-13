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
  
  gem.add_bundler_dependencies(:default, :oa_core, :development)
end
