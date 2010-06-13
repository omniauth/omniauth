version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-openid"
  gem.version = File.open(File.dirname(__FILE__) + '/VERSION', 'r').read.strip
  gem.summary = %Q{OpenID strategies for OmniAuth.}
  gem.description = %Q{OpenID strategies for OmniAuth.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.rdoc CHANGELOG.rdoc)
  
  gem.add_dependency 'oa-core', version
  gem.add_bundler_dependencies(:default, :oa_openid, :development)
end