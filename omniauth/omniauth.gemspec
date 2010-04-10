version = File.open(File.dirname(__FILE__) + '/VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "omniauth"
  gem.version = File.open(File.dirname(__FILE__) + '/VERSION', 'r').read.strip
  gem.summary = %Q{Rack middleware for standardized multi-provider authentication.}
  gem.description = %Q{OmniAuth is an authentication framework that that separates the concept of authentiation from the concept of identity, providing simple hooks for any application to have one or multiple authentication providers for a user.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.rdoc CHANGELOG.rdoc)
  
  gem.add_dependency 'oa-core', "~> #{version.gsub(/\d$/,'0')}"
  gem.add_dependency 'oa-oauth', "~> #{version.gsub(/\d$/,'0')}"
  gem.add_dependency 'oa-basic', "~> #{version.gsub(/\d$/,'0')}"
  gem.add_dependency 'oa-openid', "~> #{version.gsub(/\d$/,'0')}"
  
  gem.add_development_dependency "rspec", ">= 1.2.9"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "mg"
end