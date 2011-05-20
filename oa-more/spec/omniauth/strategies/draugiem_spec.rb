require File.expand_path('../../../spec_helper', __FILE__)

describe 'OmniAuth::Strategies::Draugiem', :type => :strategy do

  include OmniAuth::Test::StrategyTestCase

  def strategy
   [OmniAuth::Strategies::Draugiem, '123', "abc"]
  end

  it 'should initialize with api key and app id' do
    lambda{OmniAuth::Strategies::Draugiem.new({},'123','abc')}.should_not raise_error
  end

  describe '/auth/draugiem' do

    it 'should redirect to api.draugiem.lv' do
      get '/auth/draugiem'
      last_response.should be_redirect
      last_response.headers['Location'].should == "http://api.draugiem.lv/authorize/?app=123&redirect=http%3A%2F%2Fexample.org%2Fauth%2Fdraugiem%2Fcallback&hash=2d5698ba02ddd42c441998a5a2c2946b"
    end

    it 'should gather user data after success authorization' do
        stub_request(:get, "http://api.draugiem.lv/json/?action=authorize&app=abc&code=123456").
        to_return(:body => MultiJson.encode({
          'apikey'=>"123456789",
          'uid'=>"100",
          'language'=>"lv",
          'users'=>{
            '100'=>{
              'uid'=>"100",
              'name'=>"John",
              'surname'=>"Lenon",
              'nick'=>"johnybravo",
              'place'=>"Durbe",
              'age'=>"false",
              'adult'=>"1",
              'img'=>"http://4.bp.blogspot.com/_ZmXOoYjxXog/Sg2jby1RFSI/AAAAAAAAE_Q/1LpfjimAz50/s400/JohnnyBravo3.gif",
              'sex'=>"M"
            }
          }
        }))
        get '/auth/draugiem/callback?dr_auth_status=ok&dr_auth_code=123456'

        last_request.env['omniauth.auth']['credentials']['apikey'].should == "123456789"
        last_request.env['omniauth.auth']['user_info']['location'].should == "Durbe"
        last_request.env['omniauth.auth']['user_info']['age'].should be_nil
        last_request.env['omniauth.auth']['user_info']['adult'].should be_true
    end
  end
end
