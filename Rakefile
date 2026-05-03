# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:unit) do |task|
  task.pattern = "spec/lib/**/*_spec.rb"
end

RSpec::Core::RakeTask.new(:interface) do |task|
  task.pattern = "spec/interface/**/*_spec.rb"
end

task lint: :rubocop

task test: ["lint", "unit", "interface"]

task default: :test
