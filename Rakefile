require 'rubygems'
require 'rake'

begin
  require 'term/ansicolor'
  include Term::ANSIColor
rescue LoadError
  def cyan; '' end
  def blue; '' end
  def clear; '' end
  def green; '' end
  def red; '' end
end

OMNIAUTH_GEMS = %w(oa-basic oa-core oa-oauth oa-openid oa-enterprise omniauth)

def each_gem(action, &block)
  OMNIAUTH_GEMS.each_with_index do |dir, i|
    print blue, "\n\n== ", cyan, dir, blue, " ", action, clear, "\n\n"
    Dir.chdir(dir) do
      block.call(dir)
    end
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
  error_gems = []
  each_gem('specs are running...') do |jem|
    ENV['RSPEC_FORMAT'] = 'progress'
    unless system('rake spec')
      error_gems << jem
    end
  end
  
  puts
  if error_gems.any?
    puts "#{red}#{error_gems.size} gems with failing specs: #{error_gems.join(', ')}#{clear}"
    exit(1)
  else
    puts "#{green}All gems passed specs.#{clear}"
  end
end

namespace :dependencies do
  desc 'Install all dependencies via Bundler'
  task :install do
    each_gem('is installing dependencies...') do
      system('bundle install')
    end
  end
end

task :release => ['release:tag', 'gems:publish', 'doc:pages:publish']

namespace :release do
  task :tag do
    system("git tag v#{version}")
    system('git push origin --tags')
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
  task :push do
    each_gem('is releasing to Gemcutter...') do
      system('rake gem:publish')
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
    desc "Increment the major version."
    task(:major){ bump_version(0) }
    desc "Increment the minor version."
    task(:minor){ bump_version(1) }
    desc "Increment the patch version."
    task(:patch){ bump_version(2) }
  end
end

task :default => :spec

begin
  YARD_OPTS = ['-m', 'markdown', '-M', 'maruku']
  require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files   = OMNIAUTH_GEMS.inject([]){|a,g| a = a + ["#{g}/lib/**/*.rb"]; a} + ['README.markdown']
    t.options = YARD_OPTS
  end
  
  namespace :doc do
    YARD::Rake::YardocTask.new(:pages) do |t|
      t.files   = OMNIAUTH_GEMS.inject([]){|a,g| a = a + ["#{g}/lib/**/*.rb"]; a} + ['README.markdown']
      t.options = YARD_OPTS + ['-o', '../omniauth.doc']
    end
    
    namespace :pages do
      desc 'Generate and publish YARD docs to GitHub pages.'
      task :publish => ['doc:pages'] do
        Dir.chdir(File.dirname(__FILE__) + '/../omniauth.doc') do
          system("git add .")
          system("git add -u")
          system("git commit -m 'Generating docs for version #{version}.'")
          system("git push origin gh-pages")
        end
      end
    end
  end
rescue LoadError
  puts "You need to install YARD."
end