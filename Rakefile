require 'bundler/setup'
Bundler.require(:default)

require 'resque/tasks'

task "resque:setup" do
  ENV['QUEUE'] = '*'
end

desc "Run those specs"
task :spec do
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
end
