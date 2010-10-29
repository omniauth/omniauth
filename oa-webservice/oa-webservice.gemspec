require 'rubygems'
version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-webservice"
  gem.version = version
  gem.summary = %Q{WebService strategies for OmniAuth.}
  gem.description = %Q{WebService strategies for OmniAuth.}
  gem.email = "paul.chilton@gmail.com"
  gem.homepage = "http://github.com/pchilton/omniauth"
  gem.authors = ["Paul Chilton"]
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.rdoc CHANGELOG.rdoc)
  gem.add_dependency 'oa-core', version
  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
