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
    Please be sure to to drop a line in your ~/.bashrc file, similar
    to RVM if you've used that before:

    [[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

    Also ensure that you've set these variables in your ENV:
      $EDITOR, $SHELL

    You can run `tmuxinator doctor` to make sure everything is set.
    Happy tmuxing with tmuxinator!

    ..........................................................
    __________________________________________________________
  }

  spec.required_rubygems_version = ">= 1.8.23"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
end

