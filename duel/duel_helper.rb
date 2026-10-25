require 'logger'
require 'stringio'
require 'rack/mock'

# Pin OmniAuth's global configuration, which every benchmark in a worker
# shares, so no benchmark sees what another one left behind. Logging goes
# nowhere, and allowed_hosts is set, as OmniAuth recommends, so the
# request phase doesn't warn about the request's host.
OmniAuth.configure do |config|
  config.logger = Logger.new(nil)
  config.test_mode = false
  config.allowed_hosts = ['example.org']
  config.full_host = nil
  config.path_prefix = '/auth'
  config.allowed_request_methods = %i[post]
  config.request_validation_phase = OmniAuth::AuthenticityTokenProtection
  config.before_request_phase = nil
  config.after_request_phase = nil
  config.before_callback_phase = nil
  config.on_failure = OmniAuth::FailureEndpoint
  config.failure_raise_out_environments = []
end

module DuelHelper
  # The app behind the middleware, which answers every request alike.
  APP = lambda { |_env| [200, {'content-type' => 'text/plain'}, ['OK']] }

  # A strategy shaped like an OAuth 2.0 provider's: its request phase
  # redirects to the provider with the callback URL and a state, and
  # remembers the sign-in under that state, and its callback builds the
  # auth hash from what the provider sent back.
  class Provider
    include OmniAuth::Strategy

    STATE = 'b1f6c2d0a9e84f37'.freeze

    def request_phase
      remember_sign_in(STATE)
      redirect("https://provider.example/oauth/authorize?client_id=abc123&redirect_uri=#{Rack::Utils.escape(callback_url)}&state=#{STATE}")
    end

    def callback_sign_in_key
      request.params['state']
    end

    uid { request.params['uid'] }

    info do
      {
        'name' => 'Ada Lovelace',
        'email' => 'ada@example.org',
        'nickname' => 'ada',
        'image' => 'https://provider.example/avatars/ada.png'
      }
    end

    credentials do
      {'token' => 'gho_16C7e42F292c6912E7710c838347Ae178B4a', 'expires' => true, 'expires_at' => 1_800_000_000}
    end

    extra do
      {'raw_info' => {'id' => 42, 'login' => 'ada', 'site_admin' => false}}
    end
  end

  # A strategy with an other_phase, as some providers' have (for
  # metadata, say), which OmniAuth can't pass a request straight through.
  class OtherPhase
    include OmniAuth::Strategy

    def request_phase
      redirect('https://provider.example/')
    end

    def other_phase
      call_app!
    end
  end

module_function

  # A session with a CSRF token, and a token for the request phase's form
  # that's valid for it.
  def csrf_session
    session = {}
    token = Rack::Protection::AuthenticityToken.token(session)
    [session, token]
  end

  # What a provider's callback gives AuthHash.new: the typical fields,
  # and a raw_info.
  def auth_data(raw_info = {'id' => 42, 'login' => 'ada', 'site_admin' => false})
    {
      'provider' => 'github',
      'uid' => '42',
      'info' => {
        'name' => 'Ada Lovelace',
        'email' => 'ada@example.org',
        'nickname' => 'ada',
        'image' => 'https://avatars.example.org/u/42'
      },
      'credentials' => {'token' => 'gho_16C7e42F292c6912E7710c838347Ae178B4a', 'expires' => false},
      'extra' => {'raw_info' => raw_info}
    }
  end

  # A raw_info with count fields, a tenth of them nested hashes.
  def raw_info(count)
    (1..count).collect do |i|
      value = (i % 10).zero? ? {'id' => i, 'name' => "field #{i}", 'url' => "https://provider.example/#{i}"} : "value #{i}"
      ["field_#{i}", value]
    end.to_h
  end

  # count remembered sign-ins, keyed state1 to stateN, oldest first.
  def sign_ins(count)
    (1..count).collect { |i| ["state#{i}", {'origin' => "/posts/#{i}", 'params' => {'tab' => i.to_s}}] }.to_h
  end

  # A copy of env with its own session and body, for work that changes
  # them. Build these in `untimed`.
  def fresh(env, session)
    copy = env.dup
    copy['rack.session'] = session.dup
    input = env['rack.input']
    copy['rack.input'] = StringIO.new(input ? input.string : '') if input
    copy
  end

  # count fresh copies of env. Build them in `untimed`.
  def fresh_envs(env, session, count)
    Array.new(count) { fresh(env, session) }
  end

  # Calls app with each env, and checks the last response's status.
  def call_each(app, envs, status)
    response = nil
    envs.each { |env| response = app.call(env) }
    raise "Expected #{status}, got #{response[0]}" if response && response[0] != status
  end

  # The env for a request, built once.
  def env_for(path, options = {})
    Rack::MockRequest.env_for("http://example.org#{path}", options)
  end
end
