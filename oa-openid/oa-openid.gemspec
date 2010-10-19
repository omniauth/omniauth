version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-openid"
  gem.version = version
  gem.summary = %Q{OpenID strategies for OmniAuth.}
  gem.description = %Q{OpenID strategies for OmniAuth.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(LICENSE.rdoc CHANGELOG.rdoc)
  
  gem.add_dependency 'oa-core', version
  gem.add_dependency 'rack-openid', '~> 1.2.0'
  gem.add_dependency 'ruby-openid-apps-discovery'
  
  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
