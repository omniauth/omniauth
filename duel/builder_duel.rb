require_relative 'duel_helper'

# OmniAuth::Builder with five providers, as an app with several sign-in
# options has: every request passes through all five strategies.
setup do
  @app = OmniAuth::Builder.new(DuelHelper::APP) do
    %w[github google twitter facebook apple].each do |name|
      provider DuelHelper::Provider, :name => name
    end
  end
  @session, @token = DuelHelper.csrf_session
  # The first request builds the middleware stack, which is then reused.
  @app.call(DuelHelper.env_for('/', 'rack.session' => {}))
end

duel 'builder: pass through five providers' do
  once { @env = DuelHelper.env_for('/users/42/posts?page=2', 'rack.session' => @session) }
  @app.call(@env)
end

duel 'builder: request phase of the fifth provider' do |n|
  once { @env = DuelHelper.env_for('/auth/apple', :method => 'POST', :params => {'authenticity_token' => @token}) }
  envs = untimed { DuelHelper.fresh_envs(@env, @session, n) }
  DuelHelper.call_each(@app, envs, 302)
end

duel 'builder: callback of the fifth provider' do |n|
  once { @env = DuelHelper.env_for('/auth/apple/callback?uid=42&code=4a5f8e&state=b1f6c2d0a9e84f37') }
  envs = untimed { DuelHelper.fresh_envs(@env, @session, n) }
  DuelHelper.call_each(@app, envs, 200)
end
