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
    warn 'Skipping RuboCop: it is not installed. It needs CRuby 2.7 or later; run `bundle install` there.'
  end
end

begin
  require 'steep'

  desc 'Type-check lib against sig/omniauth.rbs with Steep'
  task :steep do
    sh 'rbs collection install'
    sh 'steep check'
  end
rescue LoadError
  task :steep do
    warn 'Skipping Steep: it is not installed. It needs CRuby 3.3 or later; run `bundle install` there.'
  end
end

begin
  require 'mutant'

  desc 'Run mutation tests with mutant'
  task :mutant do
    sh 'mutant run'
  end
rescue LoadError
  task :mutant do
    warn 'Skipping mutant: it is not installed. It needs CRuby 3.3 or later; run `bundle install` there.'
  end
end

task :default => %i[spec rubocop steep mutant]

namespace :perf do
  task :setup do
    require 'omniauth'
    require 'rack/test'
    require 'rack/session'
    require 'securerandom'
    app = Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, :secret => SecureRandom.hex(32)
      b.use OmniAuth::Strategies::Developer
      b.run lambda { |_env| [200, {}, ['Not Found']] }
    end.to_app
    @app = Rack::MockRequest.new(app)

    def call_app(path = ENV['GET_PATH'] || '/')
      result = @app.get(path)
      raise "Did not succeed #{result.body}" unless result.status == 200

      result
    end
  end

  task :ips => :setup do
    require 'benchmark/ips'
    Benchmark.ips do |x|
      x.report('ips') { call_app }
    end
  end

  task :mem => :setup do
    require 'memory_profiler'
    num = Integer(ENV['CNT'] || 1)
    report = MemoryProfiler.report do
      num.times { call_app }
    end
    report.pretty_print
  end
end
