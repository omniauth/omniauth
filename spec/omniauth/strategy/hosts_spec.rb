require 'helper'

# The top-level describe is OmniAuth::Strategy rather than
# OmniAuth::Strategy::Hosts so mutant keeps selecting every
# OmniAuth::Strategy example for the Hosts subjects.
describe OmniAuth::Strategy, 'hosts' do
  let(:app) { lambda { |_env| [200, {}, ['ok']] } }
  let(:options) { {} }
  let(:strategy) { ExampleStrategy.new(app, options) }

  after do
    OmniAuth.config.allowed_hosts = nil
    OmniAuth.config.full_host = nil
  end

  def env_for(path, headers = {})
    Rack::MockRequest.env_for("http://app.example#{path}", {:method => 'POST', 'rack.session' => {}}.merge(headers))
  end

  def request_phase(headers = {})
    strategy.call(env_for('/auth/test', headers))
  end

  def callback_phase(headers = {})
    strategy.call(env_for('/auth/test/callback', headers))
  end

  def expect_invalid_host
    expect(strategy.last_env).to be_nil
    expect(strategy.env['omniauth.error.type']).to eq(:invalid_host)
    expect(strategy.env['omniauth.error']).to be_a(OmniAuth::Error)
    expect(strategy.env['omniauth.error'].message).to eq('The request host is not in OmniAuth.config.allowed_hosts')
  end

  context 'with allowed hosts' do
    before { OmniAuth.config.allowed_hosts = ['app.example', /[a-z]+\.app\.example/] }

    it 'runs the request phase for an allowed host, ignoring case' do
      request_phase('HTTP_HOST' => 'APP.example')
      expect(strategy.last_env).not_to be_nil
    end

    it 'runs the request phase for a host a regexp matches' do
      request_phase('HTTP_HOST' => 'tenant.app.example')
      expect(strategy.last_env).not_to be_nil
    end

    it 'fails the request phase with :invalid_host for a forged X-Forwarded-Host' do
      response = request_phase('HTTP_X_FORWARDED_HOST' => 'evil.example')
      expect(response[0]).to eq(302)
      expect_invalid_host
    end

    it 'fails the callback phase with :invalid_host for a forged Host' do
      callback_phase('HTTP_HOST' => 'evil.example')
      expect_invalid_host
    end

    it 'runs the callback phase for an allowed host' do
      callback_phase
      expect(strategy.last_env).not_to be_nil
    end

    it 'requires a string or regexp to match the whole host' do
      request_phase('HTTP_HOST' => 'app.example.evil.example')
      expect_invalid_host
      request_phase('HTTP_HOST' => 'evil.tenant.app.example.net')
      expect_invalid_host
    end

    it 'fails when the request has no host' do
      env = env_for('/auth/test')
      env.delete('HTTP_HOST')
      env.delete('SERVER_NAME')
      strategy.call(env)
      expect_invalid_host
    end

    it "doesn't check the host when OmniAuth.config.full_host is set" do
      OmniAuth.config.full_host = 'https://app.example'
      request_phase('HTTP_HOST' => 'evil.example')
      expect(strategy.last_env).not_to be_nil
    end

    context 'and a nil full_host option' do
      let(:options) { {:full_host => nil} }

      it 'still checks the host' do
        request_phase('HTTP_HOST' => 'evil.example')
        expect_invalid_host
      end
    end

    context 'and a full_host option' do
      let(:options) { {:full_host => 'https://app.example'} }

      it "doesn't check the host" do
        callback_phase('HTTP_HOST' => 'evil.example')
        expect(strategy.last_env).not_to be_nil
      end
    end
  end

  context 'without allowed hosts' do
    before { allow(strategy).to receive(:log) }

    it 'runs the request phase for any host, warning that the host can be forged' do
      request_phase('HTTP_HOST' => 'evil.example')
      expect(strategy.last_env).not_to be_nil
      expect(strategy).to have_received(:log).with(:warn, a_string_including('X-Forwarded-Host', "OmniAuth.config.allowed_hosts = ['example.com']"))
    end

    it "doesn't warn in the callback phase" do
      callback_phase
      expect(strategy.last_env).not_to be_nil
      expect(strategy).not_to have_received(:log).with(:warn, anything)
    end

    it "doesn't warn when OmniAuth.config.allowed_hosts is set" do
      OmniAuth.config.allowed_hosts = ['app.example']
      request_phase
      expect(strategy.last_env).not_to be_nil
      expect(strategy).not_to have_received(:log).with(:warn, anything)
    end

    context 'with a full_host option' do
      let(:options) { {:full_host => 'https://app.example'} }

      it "doesn't warn" do
        request_phase
        expect(strategy.last_env).not_to be_nil
        expect(strategy).not_to have_received(:log).with(:warn, anything)
      end
    end
  end
end
