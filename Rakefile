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

OMNIAUTH_GEMS = %w(oa-basic oa-core oa-oauth oa-openid oa-enterprise oa-more omniauth)

def each_gem(action, &block)
  OMNIAUTH_GEMS.each_with_index do |dir, i|
    print blue, "\n\n== ", cyan, dir, blue, " ", action, clear, "\n\n"
    Dir.chdir(dir) do
      block.call(dir)
    end
  end
end

desc 'Run specs for all of the gems.'
task :spec do
  error_gems = []
  each_gem('specs are running...') do |gem|
    unless system('rake spec')
      error_gems << gem
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

task :release => ['release:tag', 'gems:publish', 'doc:pages:publish']

desc 'Push all gems to Gemcutter'
task :push do
  each_gem('is releasing to Gemcutter...') do
    system('rake release')
  end
end

desc 'Build all gems'
task :build do
  each_gem('is building gems...') do
    system('rake build')
  end
end

desc 'Install all gems'
task :install do
  each_gem('is installing gems...') do
    system('rake install')
  end
end

desc "Uninstall gems"
task :uninstall do
  sh "sudo gem uninstall #{OMNIAUTH_GEMS.join(" ")} -a"
end

desc "Clean pkg and other stuff"
task :clean do
  OMNIAUTH_GEMS.each do |dir|
    Dir.chdir(dir) do
      %w(tmp pkg coverage dist).each{|d| FileUtils.rm_rf d}
    end
  end
  Dir["**/*.gem"].each { |gem| FileUtils.rm_rf gem }
end

task :default => :spec
task :test => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files = OMNIAUTH_GEMS.inject([]){|a,g| a = a + ["#{g}/lib/**/*.rb"]; a} + ['README.markdown']
  end
  
  namespace :doc do
    YARD::Rake::YardocTask.new(:pages) do |t|
      t.files = OMNIAUTH_GEMS.inject([]){|a,g| a = a + ["#{g}/lib/**/*.rb"]; a} + ['README.markdown']
    end
    
    namespace :pages do
      desc 'Generate and publish YARD docs to GitHub pages.'
      task :publish => ['doc:pages'] do
        Dir.chdir(File.dirname(__FILE__) + '/../omniauth.doc') do
          system("git add .")
          system("git add -u")
          system("git push origin gh-pages")
        end
      end
    end
  end
end
