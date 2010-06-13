require 'rubygems'
require 'bundler'
Bundler.setup
require 'rake'

require 'mg'
MG.new('oa-openid.gemspec')

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << '../oa-core/lib' << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec
