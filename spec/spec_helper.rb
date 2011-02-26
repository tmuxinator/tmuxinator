$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'tmuxinator'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

SAMPLE_CONFIG = File.join(File.dirname(__FILE__), '..', 'lib', 'tmuxinator', 'assets', 'sample.yml')

RSpec.configure do |config|
  
end
