require 'rubygems'
require 'rake'
require 'term/ansicolor'

include Term::ANSIColor

OMNIAUTH_GEMS = %w(oa-core oa-basic oa-oauth oa-openid)

desc 'Run specs for all of the gems.'
task :spec do
  OMNIAUTH_GEMS.each_with_index do |dir, i|
    Dir.chdir(dir) do
      print blue, "\n\n== ", cyan, dir, blue, " specs are running...", clear, "\n\n"
      system('rake spec')
    end
  end
end

task :default => :spec
  