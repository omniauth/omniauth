require File.expand_path('../../../spec_helper', __FILE__)
require 'rack/openid'
require 'omniauth/openid'
require 'oauth'
require 'openid/store/filesystem'

describe OmniAuth::Strategies::GoogleHybrid, :type => :strategy do


  include OmniAuth::Test::StrategyTestCase

  def strategy
    [OmniAuth::Strategies::GoogleHybrid, nil,
            :name => 'google_hybrid',
            :identifier => 'https://www.google.com/accounts/o8/id', 
            :scope => ["https://www.google.com/m8/feeds/", "https://mail.google.com/mail/feed/atom/"], 
            :consumer_key => '[your key here]',
            :consumer_secret => '[your secret here]']
  end

  before do
    @identifier_url = 'https://www.google.com/accounts/o8/id' 
    # TODO: change this mock to actually return some sort of OpenID response
    stub_request(:get, @identifier_url)
  end
  
  describe 'get /auth/google_hybrid' do
    before do
      get '/auth/google_hybrid'
    end
    it 'should redirect to the Google OpenID login' do
      #last_response.should be_redirect
      #last_response.headers['Location'].should =~ %r{^#{@identifier_url}.*}
    end
  end
end
