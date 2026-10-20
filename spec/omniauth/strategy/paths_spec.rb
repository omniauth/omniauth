require 'helper'

# The top-level describe is OmniAuth::Strategy rather than
# OmniAuth::Strategy::Paths so mutant keeps selecting every
# OmniAuth::Strategy example for the Paths subjects.
describe OmniAuth::Strategy, 'paths' do
  let(:app) { lambda { |_env| [200, {}, ['ok']] } }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  def rack_env(path, props = {})
    {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => path,
      'rack.session' => {},
      'rack.input' => StringIO.new('')
    }.merge(props)
  end

  # Runs a request through the strategy (in test mode, so neither phase
  # raises) and returns the strategy, which keeps the request's env.
  def strategy_after(path, options = {}, props = {})
    strategy = ExampleStrategy.new(app, options)
    strategy.call(rack_env(path, props))
    strategy
  end

  def host_env(props = {})
    {'rack.url_scheme' => 'http', 'SERVER_NAME' => 'my.host.net', 'SERVER_PORT' => '80'}.merge(props)
  end

  context 'with a request_path lambda' do
    let(:options) { {:request_path => lambda { |env| env['PATH_INFO'] == '/login' }} }

    it 'is on the request path when the lambda returns true for the env' do
      expect(strategy_after('/login', options).on_request_path?).to be true
    end

    it 'is not on the request path when the lambda returns false for the env' do
      expect(strategy_after('/elsewhere', options).on_request_path?).to be false
    end

    it 'uses the default request path' do
      expect(strategy_after('/elsewhere', options).request_path).to eq('/auth/test')
    end
  end

  it 'uses a String subclass request_path as given' do
    path = Class.new(String).new('/custom/login')
    expect(strategy_after('/elsewhere', :request_path => path).request_path).to equal(path)
  end

  context 'callback_path' do
    it 'uses a string request_path when there is no callback_path' do
      expect(strategy_after('/elsewhere', :request_path => '/custom/login').callback_path).to eq('/custom/login')
    end

    it 'passes the env to a request_path lambda that returns a string' do
      options = {:request_path => lambda { |env| "#{env['SCRIPT_NAME']}/login" }}
      expect(strategy_after('/elsewhere', options, 'SCRIPT_NAME' => '/sub').callback_path).to eq('/sub/login')
    end

    it 'uses a String subclass returned by a request_path lambda' do
      path = Class.new(String).new('/custom/callback')
      expect(strategy_after('/elsewhere', :request_path => lambda { |_env| path }).callback_path).to equal(path)
    end

    it 'uses a String subclass callback_path as given' do
      path = Class.new(String).new('/custom/callback')
      expect(strategy_after('/elsewhere', :callback_path => path).callback_path).to equal(path)
    end

    it 'ignores a callback_path that is neither a string nor callable' do
      expect(strategy_after('/elsewhere', :callback_path => :callback).callback_path).to eq('/auth/test/callback')
    end

    it 'uses the default when a callback_path lambda returns false for the env' do
      options = {:callback_path => lambda { |env| env['PATH_INFO'] == '/done' }}
      expect(strategy_after('/elsewhere', options).callback_path).to eq('/auth/test/callback')
    end

    it 'uses the downcased current path when a callback_path lambda returns true' do
      options = {:callback_path => lambda { |env| env['PATH_INFO'] == '/Auth/Done/' }}
      expect(strategy_after('/Auth/Done/', options).callback_path).to eq('/auth/done')
    end
  end

  it 'is on a callback path that itself ends in a format extension' do
    expect(strategy_after('/auth/test/done.html', :callback_path => '/auth/test/done.html')).to be_on_callback_path
  end

  context 'setup_path' do
    it 'uses the setup_path option when there is one' do
      expect(ExampleStrategy.new(app, :setup_path => '/custom/setup').setup_path).to eq('/custom/setup')
    end

    it 'defaults to the setup path under the path prefix' do
      expect(ExampleStrategy.new(app).setup_path).to eq('/auth/test/setup')
    end
  end

  context 'script_name' do
    it 'is an empty string before a request' do
      expect(ExampleStrategy.new(app).script_name).to eq('')
    end

    it 'is an empty string when the env has no SCRIPT_NAME' do
      expect(strategy_after('/elsewhere').script_name).to eq('')
    end
  end

  context 'full_host from the request' do
    def full_host_for(props)
      strategy_after('/whatever', {}, host_env(props)).full_host
    end

    it 'drops the query string' do
      expect(full_host_for('QUERY_STRING' => 'a=b&c=d')).to eq('http://my.host.net')
    end

    it 'drops everything after the first question mark' do
      expect(full_host_for('QUERY_STRING' => 'a?b')).to eq('http://my.host.net')
    end

    it 'drops a trailing question mark in the path' do
      expect(full_host_for('PATH_INFO' => '/whatever?')).to eq('http://my.host.net')
    end

    it 'is an empty string when the request URL is not absolute' do
      expect(full_host_for('rack.url_scheme' => 'a#b')).to eq('')
    end

    it 'switches to https when only rack.url_scheme says the request is SSL' do
      # Rack itself prefers HTTP_X_FORWARDED_PROTO over rack.url_scheme.
      expect(full_host_for('rack.url_scheme' => 'https', 'HTTP_X_FORWARDED_PROTO' => 'http')).to eq('https://my.host.net')
    end

    # Strategy gems such as omniauth-facebook call full_host from specs
    # that stub #request and never run the strategy through Rack.
    context 'outside a Rack call, with a stubbed request' do
      def full_host_with_stubbed_request(props)
        strategy = ExampleStrategy.new(app)
        allow(strategy).to receive(:request).and_return(Rack::Request.new(rack_env('/whatever', host_env(props))))
        strategy.full_host
      end

      it 'uses the request scheme' do
        expect(full_host_with_stubbed_request({})).to eq('http://my.host.net')
      end

      it 'switches to https when the request is SSL' do
        expect(full_host_with_stubbed_request('HTTPS' => 'on', 'SERVER_PORT' => '443')).to eq('https://my.host.net')
      end

      it 'switches to https when a proxy forwarded HTTPS' do
        # Rack 2 and 3 disagree on the port here, so only check the scheme.
        expect(full_host_with_stubbed_request('HTTP_X_FORWARDED_PROTO' => 'https,http')).to start_with('https://my.host.net')
      end
    end
  end
end
