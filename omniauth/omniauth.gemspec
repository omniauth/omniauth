version = File.open(File.dirname(__FILE__) + '/../VERSION', 'r').read.strip

Gem::Specification.new do |gem|
  gem.name = "omniauth"
  gem.version = version
  gem.summary = %Q{Rack middleware for standardized multi-provider authentication.}
  gem.description = %Q{OmniAuth is an authentication framework that that separates the concept of authentiation from the concept of identity, providing simple hooks for any application to have one or multiple authentication providers for a user.}
  gem.email = "michael@intridea.com"
  gem.homepage = "http://github.com/intridea/omniauth"
  gem.authors = ["Michael Bleigh"]
  
  gem.files = Dir.glob("{lib}/**/*") + %w(README.rdoc LICENSE.rdoc CHANGELOG.rdoc)
  
  %w(oa-core oa-oauth oa-basic oa-openid).each do |subgem|
    gem.add_dependency subgem, version
  end

    eval File.read(File.join(File.dirname(__FILE__), '../development_dependencies.rb'))
end