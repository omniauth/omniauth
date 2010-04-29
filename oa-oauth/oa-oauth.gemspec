version = File.open(File.dirname(__FILE__) + '/VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-oauth"
  gem.version = File.open(File.dirname(__FILE__) + '/VERSION', 'r').read.strip
  gem.summary = %Q{OAuth strategies for OmniAuth.}
  gem.description = %Q{OAuth strategies for OmniAuth.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.rdoc CHANGELOG.rdoc)
  
  gem.add_dependency 'oa-core', "~> #{version.gsub(/\d$/,'0')}"
  gem.add_dependency 'oauth'
  gem.add_dependency 'oauth2'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'json'
  
  gem.add_development_dependency "rspec", ">= 1.2.9"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "mg"
end