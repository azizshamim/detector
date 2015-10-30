require 'bundler/setup'
Bundler.require(:default)

require 'resque/tasks'

task "resque:setup" do
  ENV['QUEUE'] = '*'
end

desc "Run those specs"
task :spec do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
end
