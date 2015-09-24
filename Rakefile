require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

namespace :hound do
  BASE_CMD = "git diff --no-commit-id --name-only -r master | grep rb"

  task :count do
    n = %x{#{BASE_CMD} | wc -l}.chomp
    puts "Cop'ing #{n} files"
  end

  task :check do
    cmd = "#{BASE_CMD} | xargs rubocop"
    system cmd
  end
end

task :check => ["hound:count", "hound:check"]
