# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
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

  s.required_rubygems_version = ">= 1.8.23"
  s.required_ruby_version = ">= 1.9.3"

  s.add_dependency "thor", "~> 0.19", ">= 0.15.0"
  s.add_dependency "erubis", "~> 2.6"

  s.add_development_dependency "bundler", "~> 1.3"
end

