#!/usr/bin/env ruby
$: << File.expand_path("../../lib/", __FILE__)

require "thor"
require "tmuxinator"

name = ARGV[0] || nil

if ARGV.length == 0 && Tmuxinator::Config.local?
  Tmuxinator::Cli.new.local
elsif name && !Tmuxinator::Cli::COMMANDS.keys.include?(name.to_sym) &&
      Tmuxinator::Config.exists?(name)
  Tmuxinator::Cli.new.start(name, *ARGV.drop(1))
else
  Tmuxinator::Cli.start
end
