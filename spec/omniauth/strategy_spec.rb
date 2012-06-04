require 'spec_helper'

def make_env(path = '/auth/test', props = {})
  {
    'REQUEST_METHOD' => 'GET',
    'PATH_INFO' => path,
    'rack.session' => {},
    'rack.input' => StringIO.new('test=true')
  }.merge(props)
end

describe OmniAuth::Strategy do
  let(:app){ lambda{|env| [404, {}, ['Awesome']]}}
  let(:fresh_strategy){ c = Class.new; c.send :include, OmniAuth::Strategy; c}

  describe '.default_options' do
    it 'should be inherited from a parent class' do
      superklass = Class.new
      superklass.send :include, OmniAuth::Strategy
      superklass.configure do |c|
        c.foo = 'bar'
      end

      klass = Class.new(superklass)
      klass.default_options.foo.should == 'bar'
    end
  end

  describe '.configure' do
    subject { klass = Class.new; klass.send :include, OmniAuth::Strategy; klass }
    it 'should take a block and allow for default options setting' do
      subject.configure do |c|
        c.wakka = 'doo'
      end
      subject.default_options["wakka"].should == "doo"
    end

    it 'should take a hash and deep merge it' do
      subject.configure :abc => {:def => 123}
      subject.configure :abc => {:hgi => 456}
      subject.default_options['abc'].should == {'def' => 123, 'hgi' => 456}
    end
  end

  describe '#skip_info?' do
    it 'should be true if options.skip_info is true' do
      ExampleStrategy.new(app, :skip_info => true).should be_skip_info
    end

    it 'should be false if options.skip_info is false' do
      ExampleStrategy.new(app, :skip_info => false).should_not be_skip_info
    end

    it 'should be false by default' do
      ExampleStrategy.new(app).should_not be_skip_info
    end

    it 'should be true if options.skip_info is a callable that evaluates to truthy' do
      instance = ExampleStrategy.new(app, :skip_info => lambda{|uid| uid})
      instance.should_receive(:uid).and_return(true)
      instance.should be_skip_info
    end
  end

  describe '.option' do
    subject { klass = Class.new; klass.send :include, OmniAuth::Strategy; klass }
    it 'should set a default value' do
      subject.option :abc, 123
      subject.default_options.abc.should == 123
    end

    it 'should set the default value to nil if none is provided' do
      subject.option :abc
      subject.default_options.abc.should be_nil
    end
  end

  describe '.args' do
    subject{ c = Class.new; c.send :include, OmniAuth::Strategy; c }
    it 'should set args to the specified argument if there is one' do
      subject.args [:abc, :def]
      subject.args.should == [:abc, :def]
    end

    it 'should be inheritable' do
      subject.args [:abc, :def]
      c = Class.new(subject)
      c.args.should == [:abc, :def]
    end
  end

  context 'fetcher procs' do
    subject{ fresh_strategy }
    %w(uid info credentials extra).each do |fetcher|
      it ".#{fetcher} should be able to set and retrieve a proc" do
        proc = lambda{ "Hello" }
        subject.send(fetcher, &proc)
        subject.send(fetcher).should == proc
      end
    end
  end

  context 'fetcher stacks' do
    subject{ fresh_strategy }
    %w(uid info credentials extra).each do |fetcher|
      it ".#{fetcher}_stack should be an array of called ancestral procs" do
        fetchy = Proc.new{ "Hello" }
        subject.send(fetcher, &fetchy)
        subject.send("#{fetcher}_stack", subject.new(app)).should == ["Hello"]
      end
    end
  end

  %w(request_phase).each do |abstract_method|
    it "#{abstract_method} should raise a NotImplementedError" do
      strat = Class.new
      strat.send :include, OmniAuth::Strategy
      lambda{ strat.new(app).send(abstract_method) }.should raise_error(NotImplementedError)
    end
  end

  describe '#auth_hash' do
    subject do
      klass = Class.new
      klass.send :include, OmniAuth::Strategy
      klass.option :name, 'auth_hasher'
      klass
    end
    let(:instance){ subject.new(app) }

    it 'should call through to uid and info' do
      instance.should_receive :uid
      instance.should_receive :info
      instance.auth_hash
    end

    it 'should return an AuthHash' do
      instance.stub!(:uid).and_return('123')
      instance.stub!(:info).and_return(:name => 'Hal Awesome')
      hash = instance.auth_hash
      hash.should be_kind_of(OmniAuth::AuthHash)
      hash.uid.should == '123'
      hash.info.name.should == 'Hal Awesome'
    end
  end

  describe '#initialize' do
    context 'options extraction' do
      it 'should be the last argument if the last argument is a Hash' do
        ExampleStrategy.new(app, :abc => 123).options[:abc].should == 123
      end

      it 'should be the default options if any are provided' do
        ExampleStrategy.stub!(:default_options).and_return(OmniAuth::Strategy::Options.new(:abc => 123))
        ExampleStrategy.new(app).options.abc.should == 123
      end
    end

    context 'custom args' do
      subject{ c = Class.new; c.send :include, OmniAuth::Strategy; c }
      it 'should set options based on the arguments if they are supplied' do
        subject.args [:abc, :def]
        s = subject.new app, 123, 456
        s.options[:abc].should == 123
        s.options[:def].should == 456
      end
    end
  end

  it '#call should duplicate and call' do
    klass = Class.new
    klass.send :include, OmniAuth::Strategy
    instance = klass.new(app)
    instance.should_receive(:dup).and_return(instance)
    instance.call({'rack.session' => {}})
  end

  describe '#inspect' do
    it 'should just be the class name in Ruby inspect format' do
      ExampleStrategy.new(app).inspect.should == '#<ExampleStrategy>'
    end
  end

  describe '#redirect' do
    it 'should use javascript if :iframe is true' do
      response = ExampleStrategy.new(app, :iframe => true).redirect("http://abc.com")
      response.last.body.first.should be_include("top.location.href")
    end
  end

  describe '#callback_phase' do
    subject{ k = Class.new; k.send :include, OmniAuth::Strategy; k.new(app) }

    it 'should set the auth hash' do
      env = make_env
      subject.stub!(:env).and_return(env)
      subject.stub!(:auth_hash).and_return("AUTH HASH")
      subject.callback_phase
      env['omniauth.auth'].should == "AUTH HASH"
    end
  end

  describe '#full_host' do
    let(:strategy){ ExampleStrategy.new(app, {}) }
    it 'should not freak out if there is a pipe in the URL' do
      strategy.call!(make_env('/whatever', 'rack.url_scheme' => 'http', 'SERVER_NAME' => 'facebook.lame', 'QUERY_STRING' => 'code=asofibasf|asoidnasd', 'SCRIPT_NAME' => '', 'SERVER_PORT' => 80))
      lambda{ strategy.full_host }.should_not raise_error
    end
  end

  describe '#uid' do
    subject{ fresh_strategy }
    it "should be the current class's uid if one exists" do
      subject.uid{ "Hi" }
      subject.new(app).uid.should == "Hi"
    end

    it "should inherit if it can" do
      subject.uid{ "Hi" }
      c = Class.new(subject)
      c.new(app).uid.should == "Hi"
    end
  end

  %w(info credentials extra).each do |fetcher|
    subject{ fresh_strategy }
    it "should be the current class's proc call if one exists" do
      subject.send(fetcher){ {:abc => 123} }
      subject.new(app).send(fetcher).should == {:abc => 123}
    end

    it 'should inherit by merging with preference for the latest class' do
      subject.send(fetcher){ {:abc => 123, :def => 456} }
      c = Class.new(subject)
      c.send(fetcher){ {:abc => 789} }
      c.new(app).send(fetcher).should == {:abc => 789, :def => 456}
    end
  end

  describe '#call' do
    let(:strategy){ ExampleStrategy.new(app, @options || {}) }

    context 'omniauth.origin' do
      it 'should be set on the request phase' do
        lambda{ strategy.call(make_env('/auth/test', 'HTTP_REFERER' => 'http://example.com/origin')) }.should raise_error("Request Phase")
        strategy.last_env['rack.session']['omniauth.origin'].should == 'http://example.com/origin'
      end

      it 'should be turned into an env variable on the callback phase' do
        lambda{ strategy.call(make_env('/auth/test/callback', 'rack.session' => {'omniauth.origin' => 'http://example.com/origin'})) }.should raise_error("Callback Phase")
        strategy.last_env['omniauth.origin'].should == 'http://example.com/origin'
      end

      it 'should set from the params if provided' do
        lambda{ strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'origin=/foo')) }.should raise_error('Request Phase')
        strategy.last_env['rack.session']['omniauth.origin'].should == '/foo'
      end

      it 'should be set on the failure env' do
        OmniAuth.config.should_receive(:on_failure).and_return(lambda{|env| env})
        @options = {:failure => :forced_fail}
        strategy.call(make_env('/auth/test/callback', 'rack.session' => {'omniauth.origin' => '/awesome'}))
      end

      context "with script_name" do
        it 'should be set on the request phase, containing full path' do
          env = {'HTTP_REFERER' => 'http://example.com/sub_uri/origin', 'SCRIPT_NAME' => '/sub_uri' }
          lambda{ strategy.call(make_env('/auth/test', env)) }.should raise_error("Request Phase")
          strategy.last_env['rack.session']['omniauth.origin'].should == 'http://example.com/sub_uri/origin'
        end

        it 'should be turned into an env variable on the callback phase, containing full path' do
          env = {
            'rack.session' => {'omniauth.origin' => 'http://example.com/sub_uri/origin'},
            'SCRIPT_NAME' => '/sub_uri'
          }

          lambda{ strategy.call(make_env('/auth/test/callback', env)) }.should raise_error("Callback Phase")
          strategy.last_env['omniauth.origin'].should == 'http://example.com/sub_uri/origin'
        end

      end
    end

    context 'default paths' do
      it 'should use the default request path' do
        lambda{ strategy.call(make_env) }.should raise_error("Request Phase")
      end

      it 'should be case insensitive on request path' do
        lambda{ strategy.call(make_env('/AUTH/Test'))}.should raise_error("Request Phase")
      end

      it 'should be case insensitive on callback path' do
        lambda{ strategy.call(make_env('/AUTH/TeSt/CaLlBAck'))}.should raise_error("Callback Phase")
      end

      it 'should use the default callback path' do
        lambda{ strategy.call(make_env('/auth/test/callback')) }.should raise_error("Callback Phase")
      end

      it 'should strip trailing spaces on request' do
        lambda{ strategy.call(make_env('/auth/test/')) }.should raise_error("Request Phase")
      end

      it 'should strip trailing spaces on callback' do
        lambda{ strategy.call(make_env('/auth/test/callback/')) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses the default callback_path' do
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call(make_env) }.should raise_error("Request Phase")

          strategy.callback_url.should == 'http://example.com/auth/test/callback'
        end

        it 'preserves the query parameters' do
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'id=5'))
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/auth/test/callback?id=5'
        end

        it 'consider script name' do
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call(make_env('/auth/test', 'SCRIPT_NAME' => '/sub_uri'))
          rescue RuntimeError; end
          strategy.callback_url.should == 'http://example.com/sub_uri/auth/test/callback'
        end
      end
    end

    context ':form option' do
      it 'should call through to the supplied form option if one exists' do
        strategy.options.form = lambda{|env| "Called me!"}
        strategy.call(make_env('/auth/test')).should == "Called me!"
      end

      it 'should call through to the app if :form => true is set as an option' do
        strategy.options.form = true
        strategy.call(make_env('/auth/test')).should == app.call(make_env('/auth/test'))
      end
    end

    context 'dynamic paths' do
      it 'should run the request phase if the custom request path evaluator is truthy' do
        @options = {:request_path => lambda{|env| true}}
        lambda{ strategy.call(make_env('/asoufibasfi')) }.should raise_error("Request Phase")
      end

      it 'should run the callback phase if the custom callback path evaluator is truthy' do
        @options = {:callback_path => lambda{|env| true}}
        lambda{ strategy.call(make_env('/asoufiasod')) }.should raise_error("Callback Phase")
      end

      it 'should provide a custom callback path if request_path evals to a string' do
        strategy_instance = fresh_strategy.new(nil, :request_path => lambda{|env| "/auth/boo/callback/22" })
        strategy_instance.callback_path.should == '/auth/boo/callback/22'
      end      
    end

    context 'custom paths' do
      it 'should use a custom request_path if one is provided' do
        @options = {:request_path => '/awesome'}
        lambda{ strategy.call(make_env('/awesome')) }.should raise_error("Request Phase")
      end

      it 'should use a custom callback_path if one is provided' do
        @options = {:callback_path => '/radical'}
        lambda{ strategy.call(make_env('/radical')) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses a custom callback_path if one is provided' do
          @options = {:callback_path => '/radical'}
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call(make_env('/radical')) }.should raise_error("Callback Phase")

          strategy.callback_url.should == 'http://example.com/radical'
        end

        it 'preserves the query parameters' do
          @options = {:callback_path => '/radical'}
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'id=5'))
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
        lambda{ strategy.call(make_env('/wowzers/test')) }.should raise_error("Request Phase")
      end

      it 'should use a custom prefix for callback' do
        lambda{ strategy.call(make_env('/wowzers/test/callback')) }.should raise_error("Callback Phase")
      end

      context 'callback_url' do
        it 'uses a custom prefix' do
          strategy.should_receive(:full_host).and_return('http://example.com')

          lambda{ strategy.call(make_env('/wowzers/test')) }.should raise_error("Request Phase")

          strategy.callback_url.should == 'http://example.com/wowzers/test/callback'
        end

        it 'preserves the query parameters' do
          strategy.stub(:full_host).and_return('http://example.com')
          begin
            strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'id=5'))
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
        lambda{ strategy.call(make_env)}.should_not raise_error
      end

      it 'should allow a request method of the correct type' do
        lambda{ strategy.call(make_env('/auth/test', 'REQUEST_METHOD' => 'POST'))}.should raise_error("Request Phase")
      end

      after do
        OmniAuth.config.allowed_request_methods = [:get, :post]
      end
    end

    context 'receiving an OPTIONS request' do
      shared_examples_for "an OPTIONS request" do
        it 'should respond with 200' do
          response[0].should == 200
        end

        it 'should set the Allow header properly' do
          response[1]['Allow'].should == "GET, POST"
        end
      end

      context 'to the request path' do
        let(:response) { strategy.call(make_env('/auth/test', 'REQUEST_METHOD' => 'OPTIONS')) }
        it_should_behave_like 'an OPTIONS request'
      end

      context 'to the request path' do
        let(:response) { strategy.call(make_env('/auth/test/callback', 'REQUEST_METHOD' => 'OPTIONS')) }
        it_should_behave_like 'an OPTIONS request'
      end

      context 'to some other path' do
        it 'should not short-circuit the request' do
          env = make_env('/other', 'REQUEST_METHOD' => 'OPTIONS')
          strategy.call(env).should == app.call(env)
        end
      end
    end

    context 'test mode' do
      let(:app) do
        # In test mode, the underlying app shouldn't be called on request phase.
        lambda { |env| [404, {"Content-Type" => "text/html"}, []] }
      end

      before do
        OmniAuth.config.test_mode = true
      end

      it 'should short circuit the request phase entirely' do
        response = strategy.call(make_env)
        response[0].should == 302
        response[1]['Location'].should == '/auth/test/callback'
      end

      it 'should be case insensitive on request path' do
        strategy.call(make_env('/AUTH/Test'))[0].should == 302
      end

      it 'should respect SCRIPT_NAME (a.k.a. BaseURI)' do
        response = strategy.call(make_env('/auth/test', 'SCRIPT_NAME' => '/sub_uri'))
        response[1]['Location'].should == '/sub_uri/auth/test/callback'
      end

      it 'should redirect on failure' do
        response = OmniAuth.config.on_failure.call(make_env('/auth/test', 'omniauth.error.type' => 'error'))
        response[0].should == 302
        response[1]['Location'].should == '/auth/failure?message=error'
      end

      it 'should respect SCRIPT_NAME (a.k.a. BaseURI) on failure' do
        response = OmniAuth.config.on_failure.call(make_env('/auth/test', 'SCRIPT_NAME' => '/sub_uri', 'omniauth.error.type' => 'error'))
        response[0].should == 302
        response[1]['Location'].should == '/sub_uri/auth/failure?message=error'
      end

      it 'should be case insensitive on callback path' do
        strategy.call(make_env('/AUTH/TeSt/CaLlBAck')).first.should == strategy.call(make_env('/auth/test/callback')).first
      end

      it 'should maintain query string parameters' do
        response = strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'cheese=stilton'))
        response[1]['Location'].should == '/auth/test/callback?cheese=stilton'
      end

      it 'should not short circuit requests outside of authentication' do
        strategy.call(make_env('/')).should == app.call(make_env('/'))
      end

      it 'should respond with the default hash if none is set' do
        OmniAuth.config.mock_auth[:test] = nil

        strategy.call make_env('/auth/test/callback')
        strategy.env['omniauth.auth']['uid'].should == '1234'
      end

      it 'should respond with a provider-specific hash if one is set' do
        OmniAuth.config.mock_auth[:test] = {
          'uid' => 'abc'
        }

        strategy.call make_env('/auth/test/callback')
        strategy.env['omniauth.auth']['uid'].should == 'abc'
      end

      it 'should simulate login failure if mocked data is set as a symbol' do
        OmniAuth.config.mock_auth[:test] = :invalid_credentials

        strategy.call make_env('/auth/test/callback')
        strategy.env['omniauth.error.type'].should == :invalid_credentials
      end

      it 'should set omniauth.origin on the request phase' do
        strategy.call(make_env('/auth/test', 'HTTP_REFERER' => 'http://example.com/origin'))
        strategy.env['rack.session']['omniauth.origin'].should == 'http://example.com/origin'
      end

      it 'should set omniauth.origin from the params if provided' do
        strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'origin=/foo'))
        strategy.env['rack.session']['omniauth.origin'].should == '/foo'
      end

      it 'should turn omniauth.origin into an env variable on the callback phase' do
        OmniAuth.config.mock_auth[:test] = {}

        strategy.call(make_env('/auth/test/callback', 'rack.session' => {'omniauth.origin' => 'http://example.com/origin'}))
        strategy.env['omniauth.origin'].should == 'http://example.com/origin'
      end

      it 'should set omniauth.params on the request phase' do
        OmniAuth.config.mock_auth[:test] = {}

        strategy.call(make_env('/auth/test', 'QUERY_STRING' => 'foo=bar'))
        strategy.env['rack.session']['omniauth.params'].should == {'foo' => 'bar'}
      end

      it 'should turn omniauth.params into an env variable on the callback phase' do
        OmniAuth.config.mock_auth[:test] = {}

        strategy.call(make_env('/auth/test/callback', 'rack.session' => {'omniauth.params' => {'foo' => 'bar'}}))
        strategy.env['omniauth.params'].should == {'foo' => 'bar'}
      end

      after do
        OmniAuth.config.test_mode = false
      end
    end

    context 'custom full_host' do
      before do
        OmniAuth.config.test_mode = true
      end

      it 'should be the string when a string is there' do
        OmniAuth.config.full_host = 'my.host.com'
        strategy.full_host.should == 'my.host.com'
      end

      it 'should run the proc with the env when it is a proc' do
        OmniAuth.config.full_host = Proc.new{|env| env['HOST']}
        strategy.call(make_env('/auth/test', 'HOST' => 'my.host.net'))
        strategy.full_host.should == 'my.host.net'
      end

      after do
        OmniAuth.config.test_mode = false
      end
    end
  end

  context 'setup phase' do
    before do
      OmniAuth.config.test_mode = true
    end

    context 'when options[:setup] = true' do
      let(:strategy){ ExampleStrategy.new(app, :setup => true) }
      let(:app){lambda{|env| env['omniauth.strategy'].options[:awesome] = 'sauce' if env['PATH_INFO'] == '/auth/test/setup'; [404, {}, 'Awesome'] }}

      it 'should call through to /auth/:provider/setup' do
        strategy.call(make_env('/auth/test'))
        strategy.options[:awesome].should == 'sauce'
      end

      it 'should not call through on a non-omniauth endpoint' do
        strategy.call(make_env('/somewhere/else'))
        strategy.options[:awesome].should_not == 'sauce'
      end
    end

    context 'when options[:setup] is an app' do
      let(:setup_proc) do
        Proc.new do |env|
          env['omniauth.strategy'].options[:awesome] = 'sauce'
        end
      end

      let(:strategy){ ExampleStrategy.new(app, :setup => setup_proc) }

      it 'should not call the app on a non-omniauth endpoint' do
        strategy.call(make_env('/somehwere/else'))
        strategy.options[:awesome].should_not == 'sauce'
      end

      it 'should call the rack app' do
        strategy.call(make_env('/auth/test'))
        strategy.options[:awesome].should == 'sauce'
      end
    end

    after do
      OmniAuth.config.test_mode = false
    end
  end
end