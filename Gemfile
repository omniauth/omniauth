OMNIAUTH_GEMS = %w(oa-basic oa-core oa-oauth oa-openid oa-enterprise oa-more omniauth)

OMNIAUTH_GEMS.each do |jem|
  gem jem, :path => jem
end

eval File.read(File.join(File.dirname(__FILE__), '/development_dependencies.rb'))

