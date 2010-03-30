$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'auth_elsewhere'
require 'spec'
require 'spec/autorun'
require 'rack/test'
require 'webmock/rspec'

include Rack::Test::Methods
include WebMock

Spec::Runner.configure do |config|
  
end
