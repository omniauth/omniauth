require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :test => :spec

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    $stderr.puts 'RuboCop is disabled'
  end
end

task :default => [:spec, :rubocop]
