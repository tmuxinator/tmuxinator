require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "tmuxinator"
  gem.homepage = "http://github.com/aziz/tmuxinator"
  gem.license = "MIT"
  gem.summary = %Q{Create and manage complex tmux sessions easily.}
  gem.description = %Q{Create and manage complex tmux sessions easily.}
  gem.email = "allen.bargi@gmail.com"
  gem.authors = ["Allen Bargi"]
  gem.post_install_message = %{
  __________________________________________________________
  ..........................................................

  Thank you for installing tmuxinator
  Please be sure to to drop a line in your ~/.bashrc file, similar
  to RVM if you've used that before:

  [[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

  also ensure that you've set these variables in your ENV:

  $EDITOR, $SHELL

  you can run `tmuxinator doctor` to make sure everything is set.
  happy tmuxing with tmuxinator!

  ..........................................................
  __________________________________________________________

  }

  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tmuxinator #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
