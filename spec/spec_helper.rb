require "coveralls"
require "simplecov"
require "pry"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter 'vendor/cache'
end

require "tmuxinator"
require "factory_girl"


FactoryGirl.find_definitions

RSpec.configure do |config|
  config.order = "random"
end

# Copied from minitest.
def capture_io
  begin
    require 'stringio'

    captured_stdout, captured_stderr = StringIO.new, StringIO.new

    orig_stdout, orig_stderr = $stdout, $stderr
    $stdout, $stderr         = captured_stdout, captured_stderr

    yield

    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end
end

def tmux_config(options = {})
  standard_options = [
    "assume-paste-time 1",
    "bell-action any",
    "bell-on-alert off",
  ]

  if base_index  = options.fetch(:base_index) {1}
    standard_options << "base-index #{base_index}"
  end

  if pane_base_index  = options.fetch(:pane_base_index) {1}
    standard_options << "pane-base-index #{pane_base_index}"
  end

  "echo '#{standard_options.join("\n")}'"
end
