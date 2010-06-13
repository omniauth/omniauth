require 'rubygems'
require 'rake'
require 'term/ansicolor'

include Term::ANSIColor

OMNIAUTH_GEMS = %w(oa-basic oa-core oa-oauth oa-openid omniauth)

def each_gem(action, &block)
  OMNIAUTH_GEMS.each_with_index do |dir, i|
    print blue, "\n\n== ", cyan, dir, blue, " ", action, clear, "\n\n"
    Dir.chdir(dir, &block)
  end
end

def version_file
  File.dirname(__FILE__) + '/VERSION'
end

def version 
  File.open(version_file, 'r').read.strip
end

def bump_version(position)
  v = version
  v = v.split('.').map{|s| s.to_i}
  v[position] += 1
  write_version(*v) 
end

def write_version(major, minor, patch)
  major = nil if major == ''
  minor = nil if minor == ''
  patch = nil if patch == ''
  
  v = version
  v = v.split('.').map{|s| s.to_i}
  
  v[0] = major || v[0]
  v[1] = minor || v[1]
  v[2] = patch || v[2]
  
  File.open(version_file, 'w'){ |f| f.write v.map{|i| i.to_s}.join('.') }
  puts "Version is now: #{version}"
end

desc 'Run specs for all of the gems.'
task :spec do
  each_gem('specs are running...') do
    system('rake spec')
  end
end

namespace :gems do

  desc 'Build all gems'
  task :build do
    each_gem('is building gems...') do
      system('rake gem')
    end
  end
  
  desc 'Push all gems to Gemcutter'
  task :release do
    each_gem('is releasing to Gemcutter...') do
      system('rake gemcutter')
    end
  end

  desc 'Install all gems'
  task :install do
    each_gem('is installing gems...') do
      system('rake gem:install')
    end
  end
  
  desc "Uninstall gems"
  task :uninstall do
    sh "sudo gem uninstall #{OMNIAUTH_GEMS.join(" ")} -a"
  end
  
end

desc "Clean pkg and other stuff"
task :clean do
  OMNIAUTH_GEMS.each do |dir|
    Dir.chdir(dir) do
      %w(tmp pkg coverage dist).each { |d| FileUtils.rm_rf d }
    end
  end
  Dir["**/*.gem"].each { |gem| FileUtils.rm_rf gem }
end

desc 'Display the current version.'
task :version do
  puts "Current Version: #{version}"
end

namespace :version do
  desc "Write version with MAJOR, MINOR, and PATCH level env variables."
  task :write do
    write_version(ENV['MAJOR'], ENV['MINOR'], ENV['PATCH'])
  end
  
  namespace :bump do
    task(:major){ bump_version(0) }
    task(:minor){ bump_version(1) }
    task(:patch){ bump_version(2) }
  end
end

task :default => :spec
