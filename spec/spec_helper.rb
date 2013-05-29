require "coveralls"
require "simplecov"
require "pry"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require "tmuxinator"

SAMPLE_CONFIG = File.join(File.dirname(__FILE__), "..", "lib", "tmuxinator", "assets", "sample.yml")
RBENV_SAMPLE_CONFIG = File.join(File.dirname(__FILE__), "..", "lib", "tmuxinator", "assets", "rbenv_sample.yml")

RSpec.configure do |config|
  config.order = "random"
end
