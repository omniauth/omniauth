require 'spec_helper'

class ExampleStrategy
  include OmniAuth::Strategy
  def call(env); self.call!(env) end
  attr_reader :last_env
  def request_phase
    @last_env = env
    raise "Request Phase"
  end
  def callback_phase
    raise "Callback Phase"
  end
end

describe OmniAuth::Strategy do
  let(:app){ lambda{|env| [200, {}, ['Awesome']]}}
  describe '#initialize' do
    context 'options extraction' do
      it 'should be the last argument if the last argument is a Hash' do
        ExampleStrategy.new(app, 'test', :abc => 123).options[:abc].should == 123
      end
    
      it 'should be a blank hash if none are provided' do
        ExampleStrategy.new(app, 'test').options.should == {}
      end
    end
  end
  
  describe '#call' do
    let(:strategy){ ExampleStrategy.new(app, 'test', @options) }
    
    context 'default paths' do
      it 'should use the default request path' do
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test'}) }.should raise_error("Request Phase")
      end
      
      it 'should use the default callback path' do
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET','PATH_INFO' => '/auth/test/callback'}) }.should raise_error("Callback Phase")
      end

      it 'should strip trailing spaces on request' do
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET','PATH_INFO' => '/auth/test/'}) }.should raise_error("Request Phase")        
      end

      it 'should strip trailing spaces on callback' do
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test/callback/'}) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses the default callback_path' do
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test'}) }.should raise_error("Request Phase")

          strategy.callback_url.should == 'http://example.com/auth/test/callback'
        end

        it 'preserves the query parameters' do
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test', 'QUERY_STRING' => 'id=5'})
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/auth/test/callback?id=5'
        end
      end
    end
    
    it 'should be able to modify the env on the fly before the request_phase' do
      app = lambda{|env| env['omniauth.boom'] = true; [404, {}, ['Whatev']] }
      
      s = ExampleStrategy.new(app, 'test')
      lambda{ s.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test'}) }.should raise_error("Request Phase")
      s.response.status.should == 404
      s.last_env.should be_key('omniauth.boom')
    end
    
    context 'custom paths' do
      it 'should use a custom request_path if one is provided' do
        @options = {:request_path => '/awesome'}
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/awesome'}) }.should raise_error("Request Phase")
      end
    
      it 'should use a custom callback_path if one is provided' do
        @options = {:callback_path => '/radical'}
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/radical'}) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses a custom callback_path if one is provided' do
          @options = {:callback_path => '/radical'}
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/radical'}) }.should raise_error("Callback Phase")

          strategy.callback_url.should == 'http://example.com/radical'
        end

        it 'preserves the query parameters' do
          @options = {:callback_path => '/radical'}
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call({'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => 'id=5'})
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/radical?id=5'
        end
      end
    end
    
    context 'custom prefix' do
      before do
        @options = {:path_prefix => '/wowzers'}
      end
      
      it 'should use a custom prefix for request' do
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/wowzers/test'}) }.should raise_error("Request Phase")
      end
      
      it 'should use a custom prefix for callback' do
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/wowzers/test/callback'}) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses a custom prefix' do
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/wowzers/test'}) }.should raise_error("Request Phase")

          strategy.callback_url.should == 'http://example.com/wowzers/test/callback'
        end

        it 'preserves the query parameters' do
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/wowzers/test', 'QUERY_STRING' => 'id=5'})
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/wowzers/test/callback?id=5'
        end
      end
    end
    
    context 'request method restriction' do
      before do
        OmniAuth.config.allowed_request_methods = [:post]
      end
      
      it 'should not allow a request method of the wrong type' do
        lambda{ strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test'})}.should_not raise_error
      end
      
      it 'should allow a request method of the correct type' do
        lambda{ strategy.call({'REQUEST_METHOD' => 'POST', 'PATH_INFO' => '/auth/test'})}.should raise_error("Request Phase")
      end
      
      after do
        OmniAuth.config.allowed_request_methods = [:get, :post]        
      end
    end

    context 'test mode' do
      before do
        OmniAuth.config.test_mode = true
      end

      it 'should short circuit the request phase entirely' do
        response = strategy.call({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test'})
        response[0].should == 302
        response[1]['Location'].should == '/auth/test/callback'
      end

      it 'should not short circuit requests outside of authentication' do
        env = {'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/'}
        strategy.call(env).should == app.call(env)
      end

      it 'should respond with the default hash if none is set' do
        strategy.call 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test/callback'
        strategy.env['omniauth.auth']['uid'].should == '1234'
      end

      it 'should respond with a provider-specific hash if one is set' do
        OmniAuth.config.mock_auth[:test] = {
          'uid' => 'abc'
        }

        strategy.call 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/auth/test/callback'
        strategy.env['omniauth.auth']['uid'].should == 'abc'
      end
    end

    context 'custom full_host' do
      it 'should be the string when a string is there' do
        OmniAuth.config.full_host = 'my.host.com'
        strategy.full_host.should == 'my.host.com'
      end

      it 'should run the proc with the env when it is a proc' do
        OmniAuth.config.full_host = Proc.new{|env| env['HOST']}
        strategy.call('REQUEST_METHOD' => 'GET', 'HOST' => 'my.host.net')
        strategy.full_host.should == 'my.host.net'
      end
    end
  end
end
