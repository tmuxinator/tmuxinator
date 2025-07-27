# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tmuxinator/version"

Gem::Specification.new do |s|
  s.name          = "tmuxinator"
  s.version       = Tmuxinator::VERSION
  s.authors       = ["Allen Bargi", "Christopher Chow"]
  s.email         = ["allen.bargi@gmail.com", "chris@chowie.net"]
  s.description   = %q{Create and manage complex tmux sessions easily.}
  s.summary       = %q{Create and manage complex tmux sessions easily.}
  s.homepage      = "https://github.com/tmuxinator/tmuxinator"
  s.license       = "MIT"

  s.files         = Dir["lib/**/*", "spec/**/*", "bin/*", "completion/*"]
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.post_install_message = %q{
    __________________________________________________________
    ..........................................................

    Thank you for installing tmuxinator.

    Make sure that you've set these variables in your ENV:

      $EDITOR, $SHELL

    You can run `tmuxinator doctor` to make sure everything is set.
    Happy tmuxing with tmuxinator!

    ..........................................................
    __________________________________________________________
  }

  s.required_rubygems_version = Gem::Requirement.new(">= 2.7")
  s.required_ruby_version = ">= 2.7"

  s.add_dependency "erubi", "~> 1.13"
  s.add_dependency "thor", "~> 1.4.0"

  s.add_development_dependency "amazing_print", "~> 1.8"
  s.add_development_dependency "bundler", ">= 1.3"
  s.add_development_dependency "factory_bot", "~> 6.5"
  s.add_development_dependency "pry", "~> 0.15"
  s.add_development_dependency "rake", "~> 13.3"
  s.add_development_dependency "rspec", "~> 3.13"
  s.add_development_dependency "rubocop", "~> 1.79"
  s.add_development_dependency "simplecov", "~> 0.22"
end
