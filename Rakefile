OMNIAUTH_GEMS = %w(oa-basic oa-core oa-oauth oa-openid oa-enterprise oa-more)

def each_gem(action, &block)
  OMNIAUTH_GEMS.each do |gem|
    puts "#{gem} #{action}"
    Dir.chdir(gem) do
      yield
    end
  end
end

def version
  File.read("VERSION").strip
end

def bump_version(position)
  v = version.split('.').map{|s| s.to_i}
  v[position] += 1
  write_version(*v)
end

def write_version(major, minor, patch)
  v = version.split('.').map{|s| s.to_i}
  v[0] = major unless major.nil?
  v[1] = minor unless minor.nil?
  v[2] = patch unless patch.nil?
  File.open("VERSION", 'w') do |f|
    f.write v.join('.')
  end
  each_gem('is writing version file...') do
    File.open("VERSION", 'w') do |f|
      f.write v.join('.')
    end
  end
  display_version
end

def display_version
  puts "Version is now #{version}"
end

desc "Display the current version"
task :version do
  display_version
end

namespace :version do
  desc "Write version with MAJOR, MINOR, and PATCH level env variables."
  task :write do
    write_version(ENV['MAJOR'], ENV['MINOR'], ENV['PATCH'])
  end

  namespace :bump do
    desc "Increment the major version"
    task :major do
      bump_version(0)
    end
    desc "Increment the minor version"
    task :minor do
      bump_version(1)
    end
    desc "Increment the patch version"
    task :patch do
      bump_version(2)
    end
  end
end

desc "Run specs for all of the gems"
task :spec do
  error_gems = []
  each_gem('specs are running...') do |gem|
    unless system('bundle exec rake spec')
      error_gems << gem
    end
  end

  puts
  if error_gems.any?
    puts "#{error_gems.size} gems with failing specs: #{error_gems.join(', ')}"
    exit(1)
  else
    puts "All gems passed specs."
  end
end

desc "Release all gems to gemcutter and create a tag"
task :release => ['tag', 'clean', 'build', 'publish']

task :tag do
  system("git tag v#{version.join}")
  system('git push origin --tags')
end

task :publish do
  each_gem('is releasing to Rubygems...') do
    system("gem push pkg/#{gem}-#{version.join}.gem")
  end
  system("gem push pkg/omniauth-#{version.join}.gem")
end

def build_gem
  system('gem build omniauth.gemspec')
  FileUtils.mkdir_p('pkg')
  FileUtils.mv("omniauth-#{version}.gem", 'pkg')
end

def install_gem
  system("gem install pkg/omniauth-#{version}.gem")
end

desc "Build gem files for all projects"
task :build do
  each_gem('is building...') do
    system('rake build')
  end
  build_gem
end

desc "Install gems for all projects"
task :install do
  each_gem('is installing...') do
    system('rake install')
  end
  build_gem
  install_gem
end

desc "Clean pkg and other stuff"
task :clean do
  OMNIAUTH_GEMS.each do |gem|
    Dir.chdir(gem) do
      %w(tmp pkg coverage dist).each do |directory|
        FileUtils.rm_rf directory
      end
    end
    %w(tmp pkg coverage dist).each do |directory|
      FileUtils.rm_rf directory
    end
  end
  Dir["**/*.gem"].each do |gem|
    FileUtils.rm_rf gem
  end
end

task :default => :spec
task :test => :spec

namespace :doc do
  require 'yard'
  YARD::Rake::YardocTask.new do |task|
    task.files = OMNIAUTH_GEMS.map{|gem| ["#{gem}/lib/**/*.rb"]} + ['README.markdown', 'LICENSE']
    task.options = [
      '--markup', 'markdown',
      '--markup-provider', 'maruku',
    ]
  end
end
