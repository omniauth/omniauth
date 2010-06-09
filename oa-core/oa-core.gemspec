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
  
  gem.add_dependency 'rack'
  
  gem.add_development_dependency "rspec", ">= 1.2.9"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "mg"
end
