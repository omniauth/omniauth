require 'rubygems'

version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "oa-cookie"
  gem.version = version
  gem.summary = %Q{Cookie strategies for OmniAuth.}
  gem.description = %Q{Cookie strategies for OmniAuth.}
  gem.email = "rainux@gmail.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Rainux Luo"]

  gem.files = Dir.glob("{lib}/**/*") + %w(README.markdown LICENSE.rdoc CHANGELOG.rdoc)

  gem.add_dependency  'oa-core',    version
  gem.add_dependency  'multi_json', '~> 0.0.2'

  eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end
