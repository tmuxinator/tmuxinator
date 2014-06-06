# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tmuxinator/version"

Gem::Specification.new do |spec|
  spec.name          = "tmuxinator"
  spec.version       = Tmuxinator::VERSION
  spec.authors       = ["Allen Bargi"]
  spec.email         = ["allen.bargi@gmail.com"]
  spec.description   = %q{Create and manage complex tmux sessions easily.}
  spec.summary       = %q{Create and manage complex tmux sessions easily.}
  spec.homepage      = "https://github.com/aziz/tmuxinator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.post_install_message = %q{
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

  spec.required_rubygems_version = ">= 1.8.23"

  spec.add_dependency "thor", "~> 0.19", ">= 0.15.0"
  spec.add_dependency "erubis"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "factory_girl"
  spec.add_development_dependency "transpec"
end

