require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'OmniAuth::Strategies::Renren' do

  before do
    OmniAuth::Strategies::Renren.stub!(:verify_signature).and_return(true)
  end

  def app
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use OmniAuth::Builder do
        provider :renren, 'abc', 'def'
      end
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, [env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  def session
    last_request.env['rack.session']
  end

  describe '/auth/{name}/callback' do
    before do
      stub_request(:post, 'http://api.renren.com/restserver.do').
        to_return(:body => '[{"uid":245699638,"tinyurl":"http://hdn.xnimg.cn/photos/hdn221/20091007/0135/tiny_0339_9269c019116.jpg","vip":1,"sex":1,"name":"Rainux","star":1,"headurl":"http://hdn.xnimg.cn/photos/hdn221/20091007/0135/head_0Y0Q_9284k019116.jpg","zidou":0}]')
      get '/auth/renren/callback'
    end

    it 'should set the api_key and secret_key' do
      OmniAuth::Strategies::Renren.api_key.should == 'abc'
      OmniAuth::Strategies::Renren.secret_key.should == 'def'
    end

    it 'should exchange the request token for an access token' do
      last_request.env['omniauth.auth']['provider'].should == 'renren'
      last_request.env['omniauth.auth']['extra']['renren_session'].should be_kind_of(OmniAuth::Strategies::Renren::Session)
    end

    it 'should call through to the master app' do
      last_response.body.should == 'true'
    end
  end
end
