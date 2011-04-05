require 'rubygems'
require 'rspec'
require 'rspec/autorun'
require 'rack/test'
require 'webmock/rspec'

include Rack::Test::Methods
include WebMock::API

require 'omniauth/basic'

WebMock.disable_net_connect!
