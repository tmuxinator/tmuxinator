require "coveralls"
require "simplecov"
require "pry"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require "tmuxinator"
require "factory_girl"

FactoryGirl.find_definitions

SAMPLE_CONFIG = File.join(File.dirname(__FILE__), "..", "lib", "tmuxinator", "assets", "sample.yml")
RBENV_SAMPLE_CONFIG = File.join(File.dirname(__FILE__), "..", "lib", "tmuxinator", "assets", "rbenv_sample.yml")

RSpec.configure do |config|
  config.order = "random"
end

# Copied from minitest.
def capture_io
  require 'stringio'

  orig_stdout, orig_stderr = $stdout, $stderr
  captured_stdout, captured_stderr = StringIO.new, StringIO.new
  $stdout, $stderr = captured_stdout, captured_stderr

  yield

  return captured_stdout.string, captured_stderr.string
ensure
  $stdout = orig_stdout
  $stderr = orig_stderr
end
