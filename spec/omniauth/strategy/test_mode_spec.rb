require 'helper'

# The top-level describe is OmniAuth::Strategy rather than
# OmniAuth::Strategy::TestMode so mutant keeps selecting every
# OmniAuth::Strategy example for the TestMode subjects.
describe OmniAuth::Strategy, 'test mode' do
  let(:app) { lambda { |env| [200, {}, [env.key?('omniauth.auth').to_s]] } }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:test)
  end

  def rack_env(path, props = {})
    {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => path,
      'rack.session' => {},
      'rack.input' => StringIO.new('')
    }.merge(props)
  end

  it 'passes requests outside of authentication to the app without mocking a callback' do
    expect(ExampleStrategy.new(app).call(rack_env('/elsewhere'))).to eq([200, {}, ['false']])
  end

  context 'on the callback path' do
    it 'runs the setup phase' do
      strategy = ExampleStrategy.new(app, :setup => lambda { |env| env['setup.ran'] = true })
      strategy.call(rack_env('/auth/test/callback'))
      expect(strategy.env['setup.ran']).to be true
    end

    it 'sets omniauth.params to an empty hash when the session has none' do
      strategy = ExampleStrategy.new(app)
      strategy.call(rack_env('/auth/test/callback'))
      expect(strategy.env['omniauth.params']).to eq({})
    end

    it 'does not set omniauth.auth when a failure is mocked' do
      OmniAuth.config.mock_auth[:test] = :invalid_credentials
      strategy = ExampleStrategy.new(app)
      strategy.call(rack_env('/auth/test/callback'))
      expect(strategy.env).not_to have_key('omniauth.auth')
      expect(strategy.env['omniauth.error.type']).to eq(:invalid_credentials)
    end
  end
end
