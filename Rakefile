require "bundler/gem_tasks"
require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new
RSpec::Core::RakeTask.new(:integration) do |t|
  t.rspec_opts = "--tag integration"
end
task :test => ["spec", "rubocop", "integration"]
