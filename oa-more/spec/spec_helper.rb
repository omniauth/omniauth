require 'rubygems'
require 'rspec'
require 'rspec/autorun'
require 'rack/test'
require 'webmock/rspec'

include Rack::Test::Methods
include WebMock::API

require 'omniauth/more'

WebMock.disable_net_connect!
