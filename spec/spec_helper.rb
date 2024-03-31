# frozen_string_literal: true

require "coveralls"
require "pry"
require "simplecov"
require "xdg"

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)
SimpleCov.start do
  add_filter "vendor/cache"
end

require "tmuxinator"
require "factory_bot"

FactoryBot.find_definitions

# Custom Matchers
require_relative "matchers/pane_matcher"

RSpec.configure do |config|
  config.order = "random"
end

# Copied from minitest.
def capture_io
  require "stringio"

  captured_stdout = StringIO.new
  captured_stderr = StringIO.new

  orig_stdout = $stdout
  orig_stderr = $stderr

  $stdout = captured_stdout
  $stderr = captured_stderr

  yield

  [captured_stdout.string, captured_stderr.string]
ensure
  $stdout = orig_stdout
  $stderr = orig_stderr
end

def tmux_config(options = {})
  standard_options = [
    "assume-paste-time 1",
    "bell-action any",
    "bell-on-alert off",
  ]

  if base_index = options.fetch(:base_index) { 1 }
    standard_options << "base-index #{base_index}"
  end

  if pane_base_index = options.fetch(:pane_base_index) { 1 }
    standard_options << "pane-base-index #{pane_base_index}"
  end

  "echo '#{standard_options.join("\n")}'"
end
