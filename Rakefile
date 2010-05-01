require 'rubygems'
require 'rake'
require 'term/ansicolor'

include Term::ANSIColor

OMNIAUTH_GEMS = %w(omniauth oa-core oa-oauth oa-openid)

desc 'Run specs for all of the gems.'
task :spec do
  OMNIAUTH_GEMS.each_with_index do |dir, i|
    Dir.chdir(dir) do
      print blue, "\n\n== ", cyan, dir, blue, " specs are running...", clear, "\n\n"
      system('rake spec')
    end
  end
end

desc 'Push all gems to Gemcutter'
task :gemcutter do
  OMNIAUTH_GEMS.each_with_index do |dir, i|
    Dir.chdir(dir) { system('rake gemcutter') }
  end  
end

task :default => :spec
  