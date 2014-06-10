# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tmuxinator/version"

Gem::Specification.new do |s|
  s.name          = "tmuxinator"
  s.version       = Tmuxinator::VERSION
  s.authors       = ["Allen Bargi"]
  s.email         = ["allen.bargi@gmail.com"]
  s.description   = %q{Create and manage complex tmux sessions easily.}
  s.summary       = %q{Create and manage complex tmux sessions easily.}
  s.homepage      = "https://github.com/aziz/tmuxinator"
  s.license       = "MIT"

  s.files         = Dir['lib/**/*', 'spec/**/*', 'bin/*']
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

  s.add_dependency "thor", "~> 0.18", ">= 0.18.0"
  s.add_dependency "erubis"

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rspec", "~> 3.0.0"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "transpec"
end

