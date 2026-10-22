require 'helper'
require 'json'

# A strategy whose provider sends the request phase's key param back to the
# callback, the way an OAuth 2.0 provider sends back the state.
class SignInStrategy
  include OmniAuth::Strategy

  option :name, 'test'

  def request_phase
    remember_sign_in(request.params.fetch('key'))
    redirect "https://provider.example/?key=#{request.params.fetch('key')}"
  end

  def callback_sign_in_key
    request.params['key']
  end

  def callback_phase
    call_app!
  end
end

# The top-level describe is OmniAuth::Strategy rather than
# OmniAuth::Strategy::SignIns so mutant keeps selecting every
# OmniAuth::Strategy example for the SignIns subjects.
describe OmniAuth::Strategy, 'sign-ins' do
  let(:app) { lambda { |env| [200, {}, [JSON.generate([env['omniauth.origin'], env['omniauth.params']])]] } }
  let(:strategy) { SignInStrategy.new(app) }
  let(:session) { {} }

  around do |example|
    validation_phase = OmniAuth.config.request_validation_phase
    OmniAuth.config.request_validation_phase = nil
    example.run
  ensure
    OmniAuth.config.request_validation_phase = validation_phase
  end

  def start(key, origin = "/#{key}")
    response = strategy.call(Rack::MockRequest.env_for("http://app.example/auth/test?key=#{key}&origin=#{origin}", :method => 'POST', 'rack.session' => session))
    expect(response[1]['Location']).to eq("https://provider.example/?key=#{key}")
  end

  def finish(key)
    query = Rack::Utils.build_query('key' => key)
    response = strategy.call(Rack::MockRequest.env_for("http://app.example/auth/test/callback?#{query}", 'rack.session' => session))
    JSON.parse(response[2].join)
  end

  it "gives each callback its own sign-in's origin and params, in any order" do
    start('a')
    start('b')
    expect(session['omniauth.sign_ins'].keys).to eq(%w[a b])
    expect(finish('a')).to eq(['/a', {'key' => 'a', 'origin' => '/a'}])
    expect(session['omniauth.sign_ins'].keys).to eq(%w[b])
    expect(session.keys).not_to include('omniauth.origin', 'omniauth.params')
    expect(finish('b')).to eq(['/b', {'key' => 'b', 'origin' => '/b'}])
    expect(session['omniauth.sign_ins']).to eq({})
  end

  it "remembers the latest #{OmniAuth::Strategy::SignIns::MAX_REMEMBERED_SIGN_INS}, forgetting the oldest" do
    keys = %w[a b c d e f]
    keys.each { |key| start(key) }
    expect(session['omniauth.sign_ins'].keys).to eq(keys.drop(1))
    expect(finish('a')).to eq(['/f', {'key' => 'f', 'origin' => '/f'}])
    expect(finish('b')).to eq(['/b', {'key' => 'b', 'origin' => '/b'}])
  end

  it 'moves a reused key to the newest place, with its new origin' do
    start('a')
    start('b')
    start('a', '/again')
    expect(session['omniauth.sign_ins'].keys).to eq(%w[b a])
    expect(finish('a').first).to eq('/again')
  end

  it 'falls back to omniauth.origin and omniauth.params for a key it never remembered' do
    start('a')
    expect(finish('z')).to eq(['/a', {'key' => 'a', 'origin' => '/a'}])
    expect(session['omniauth.sign_ins'].keys).to eq(%w[a])
  end

  it 'falls back when the callback has no key, or one that is not a string' do
    start('a')
    session['omniauth.origin'] = '/latest'
    expect(strategy.call(Rack::MockRequest.env_for('http://app.example/auth/test/callback?key[]=a', 'rack.session' => session))[2].join).to include('/latest')
    expect(session['omniauth.sign_ins'].keys).to eq(%w[a])
  end

  it "doesn't remember an empty key" do
    start('')
    expect(session).not_to have_key('omniauth.sign_ins')
  end

  it 'remembers a sign-in without an origin' do
    strategy.call(Rack::MockRequest.env_for('http://app.example/auth/test?key=a', :method => 'POST', 'rack.session' => session))
    expect(session['omniauth.sign_ins']).to eq('a' => {'origin' => nil, 'params' => {'key' => 'a'}})
    expect(finish('a')).to eq([nil, {'key' => 'a'}])
  end

  it 'gives a nil origin for a remembered empty origin' do
    start('a', '')
    expect(finish('a').first).to be_nil
  end

  it 'replaces remembered sign-ins that are not a hash' do
    session['omniauth.sign_ins'] = 'junk'
    start('a')
    expect(session['omniauth.sign_ins'].keys).to eq(%w[a])
    session['omniauth.sign_ins'] = 'junk'
    session['omniauth.origin'] = '/latest'
    expect(finish('a').first).to eq('/latest')
  end

  it 'accepts remembered sign-ins in a Hash subclass, like HashWithIndifferentAccess' do
    start('a')
    session['omniauth.sign_ins'] = Class.new(Hash).new.merge!(session['omniauth.sign_ins'])
    session.delete('omniauth.origin')
    expect(finish('a').first).to eq('/a')
  end

  it 'changes remembered sign-ins by assigning the session key, not in place' do
    start('a')
    start('b')
    session['omniauth.sign_ins'].freeze
    expect(finish('a').first).to eq('/a')
    session['omniauth.sign_ins'].freeze
    start('c')
    expect(session['omniauth.sign_ins'].keys).to eq(%w[b c])
  end

  it "keeps a single origin and params for a strategy that doesn't remember sign-ins" do
    strategy = ExampleStrategy.new(app)
    strategy.call(Rack::MockRequest.env_for('http://app.example/auth/test?origin=/a', :method => 'POST', 'rack.session' => session))
    expect(session.keys).to contain_exactly('omniauth.origin', 'omniauth.params')
    expect(strategy.callback_sign_in_key).to be_nil
  end
end
