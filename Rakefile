require 'bundler/setup'
Bundler.require(:default)

require 'resque/tasks'

task "resque:setup" do
  ENV['QUEUE'] = '*'
end

desc "Run those specs"
task :spec do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
    t.pattern = 'spec/**/*_spec.rb'
  end
end
