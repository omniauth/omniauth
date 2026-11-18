require_relative 'duel_helper'

# The callback phase builds the auth hash and calls the app. It takes the
# sign-in's origin and params out of the session, so each iteration gets
# fresh copies, made untimed.

duel 'callback: the developer strategy' do |n|
  once do
    @strategy = OmniAuth::Strategies::Developer.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/auth/developer/callback?name=Ada+Lovelace&email=ada%40example.org')
    @session = {'omniauth.origin' => '/dashboard', 'omniauth.params' => {'origin' => '/dashboard'}}
  end
  envs = untimed { DuelHelper.fresh_envs(@env, @session, n) }
  DuelHelper.call_each(@strategy, envs, 200)
end

duel 'callback: a provider' do |n|
  once do
    @strategy = DuelHelper::Provider.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/auth/provider/callback?uid=42&code=4a5f8e&state=b1f6c2d0a9e84f37')
    @session = {'omniauth.origin' => '/dashboard', 'omniauth.params' => {}}
  end
  envs = untimed { DuelHelper.fresh_envs(@env, @session, n) }
  DuelHelper.call_each(@strategy, envs, 200)
end

# The newest of the five sign-ins that OmniAuth keeps, which it finds
# last, comparing each key in constant time.
duel 'callback: a provider, with five sign-ins kept' do |n|
  once do
    @strategy = DuelHelper::Provider.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/auth/provider/callback?uid=42&code=4a5f8e&state=state5')
    @session = {'omniauth.sign_ins' => DuelHelper.sign_ins(OmniAuth::Strategy::SignIns::MAX_REMEMBERED_SIGN_INS)}
  end
  envs = untimed { DuelHelper.fresh_envs(@env, @session, n) }
  DuelHelper.call_each(@strategy, envs, 200)
end
