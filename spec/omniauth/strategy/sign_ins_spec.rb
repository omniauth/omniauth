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

# A strategy that stores its own data in each sign-in, the way an OAuth 2.0
# strategy stores its PKCE verifier, and reads it back in the callback.
class SignInDataStrategy < SignInStrategy
  def request_phase
    key = request.params.fetch('key')
    remember_sign_in(key, 'verifier' => "verifier-#{key}")
    redirect "https://provider.example/?key=#{key}"
  end

  def callback_phase
    [200, {}, [JSON.generate([remembered_sign_in, remembered_sign_in.equal?(remembered_sign_in), env['omniauth.origin']])]]
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
    expect(OmniAuth::Strategy::SignIns::MAX_REMEMBERED_SIGN_INS).to eq(3)
    keys = %w[a b c d]
    keys.each { |key| start(key) }
    expect(session['omniauth.sign_ins'].keys).to eq(keys.drop(1))
    expect(finish('a')).to eq(['/d', {'key' => 'd', 'origin' => '/d'}])
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

  it "doesn't write sign-ins to the session for a callback whose key isn't remembered" do
    session['omniauth.sign_ins'] = {'a' => {}}.freeze
    finish('z')
    expect(session['omniauth.sign_ins']).to be_frozen
    session.delete('omniauth.sign_ins')
    finish('z')
    expect(session).not_to have_key('omniauth.sign_ins')
  end

  it "doesn't remember an empty key" do
    start('')
    expect(session).not_to have_key('omniauth.sign_ins')
  end

  it 'remembers a sign-in without an origin' do
    strategy.call(Rack::MockRequest.env_for('http://app.example/auth/test?key=a', :method => 'POST', 'rack.session' => session))
    expect(session['omniauth.sign_ins']).to eq('a' => {'params' => {'key' => 'a'}})
    expect(finish('a')).to eq([nil, {'key' => 'a'}])
  end

  it 'remembers a sign-in outside the request phase, as when a strategy calls it directly' do
    env = Rack::MockRequest.env_for('http://app.example/', 'rack.session' => session)
    strategy.instance_variable_set(:@env, env)
    strategy.remember_sign_in('a')
    expect(session['omniauth.sign_ins']).to eq('a' => {})
  end

  it 'leaves out an empty origin, giving the callback a nil origin' do
    start('a', '')
    expect(session['omniauth.sign_ins']['a']).not_to have_key('origin')
    expect(finish('a').first).to be_nil
  end

  it 'leaves out empty params, giving the callback empty params' do
    env = Rack::MockRequest.env_for('http://app.example/', 'rack.session' => session)
    strategy.instance_variable_set(:@env, env)
    session['omniauth.origin'] = '/a'
    session['omniauth.params'] = {}
    strategy.remember_sign_in('a')
    expect(session['omniauth.sign_ins']).to eq('a' => {'origin' => '/a'})
    expect(finish('a')).to eq(['/a', {}])
  end

  it "leaves out params larger than #{OmniAuth::Strategy::SignIns::MAX_REMEMBERED_PARAMS_BYTESIZE} bytes, with a warning" do
    max = OmniAuth::Strategy::SignIns::MAX_REMEMBERED_PARAMS_BYTESIZE
    expect(max).to eq(512)
    allow(OmniAuth.logger).to receive(:warn)
    request = lambda do |key, size|
      env = Rack::MockRequest.env_for("http://app.example/auth/test?key=#{key}&origin=/#{key}&x=#{'x' * size}", :method => 'POST', 'rack.session' => session)
      strategy.call(env)
    end
    # The keys and the values of key and origin are 13 bytes, so this fills
    # the limit exactly.
    request.call('a', max - 13)
    expect(session['omniauth.sign_ins']['a'].fetch('params').keys).to eq(%w[key origin x])
    request.call('b', max - 12)
    expect(session['omniauth.sign_ins']['b']).to eq('origin' => '/b')
    expect(OmniAuth.logger).to have_received(:warn).with(/Not remembering/).once
    expect(OmniAuth.logger).to have_received(:warn).with("(test) Not remembering #{max + 1} bytes of params for this sign-in, more than #{max}. The callback gets empty omniauth.params.")
    expect(finish('b')).to eq(['/b', {}])
  end

  it 'counts the bytes of nested params, in hashes and arrays' do
    max = OmniAuth::Strategy::SignIns::MAX_REMEMBERED_PARAMS_BYTESIZE
    allow(OmniAuth.logger).to receive(:warn)
    env = Rack::MockRequest.env_for('http://app.example/', 'rack.session' => session)
    strategy.instance_variable_set(:@env, env)
    # a, xx, b, c, d, and eee are 9 bytes besides the long value, and nil
    # counts as none.
    nested = ->(size) { {'a' => ['xx', {'b' => 'x' * size}], 'c' => nil, :d => 'eee'} }
    session['omniauth.params'] = nested.call(max - 9)
    strategy.remember_sign_in('a')
    expect(session['omniauth.sign_ins']['a']).to have_key('params')
    session['omniauth.params'] = nested.call(max - 8)
    strategy.remember_sign_in('b')
    expect(session['omniauth.sign_ins']['b']).to eq({})
    expect(OmniAuth.logger).to have_received(:warn).with(/Not remembering #{max + 1} bytes/).once
  end

  it "doesn't change the data the strategy passes" do
    env = Rack::MockRequest.env_for('http://app.example/', 'rack.session' => session)
    strategy.instance_variable_set(:@env, env)
    session['omniauth.origin'] = '/a'
    data = {'verifier' => 'v'}.freeze
    strategy.remember_sign_in('a', data)
    expect(session['omniauth.sign_ins']).to eq('a' => {'verifier' => 'v', 'origin' => '/a'})
  end

  it "stores the strategy's own data in the sign-in, for the callback to read" do
    strategy = SignInDataStrategy.new(app)
    env = ->(path) { Rack::MockRequest.env_for("http://app.example/auth/test#{path}", :method => 'POST', 'rack.session' => session) }
    strategy.call(env.call('?key=a&origin=/a'))
    strategy.call(env.call('?key=b&origin=/b'))
    expect(session['omniauth.sign_ins']).to eq(
      'a' => {'verifier' => 'verifier-a', 'origin' => '/a', 'params' => {'key' => 'a', 'origin' => '/a'}},
      'b' => {'verifier' => 'verifier-b', 'origin' => '/b', 'params' => {'key' => 'b', 'origin' => '/b'}}
    )
    body = strategy.call(env.call('/callback?key=a'))[2].join
    expect(JSON.parse(body)).to eq([{'verifier' => 'verifier-a', 'origin' => '/a', 'params' => {'key' => 'a', 'origin' => '/a'}}, true, '/a'])
    expect(session['omniauth.sign_ins'].keys).to eq(%w[b])
    expect(JSON.parse(strategy.call(env.call('/callback?key=z'))[2].join)).to eq([nil, true, nil])
    expect(session['omniauth.sign_ins'].keys).to eq(%w[b])
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
