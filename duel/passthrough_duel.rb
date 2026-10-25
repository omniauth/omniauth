require_relative 'duel_helper'

# Every strategy sits in the middleware stack of every request, so the
# requests that aren't for it, which it hands straight to the app, are
# OmniAuth's hottest path. None of these change the env, so each is
# built once.

duel 'passthrough: a typical path' do
  once do
    @strategy = OmniAuth::Strategies::Developer.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/users/42/posts?page=2', 'rack.session' => {})
  end
  @strategy.call(@env)
end

duel 'passthrough: the root path' do
  once do
    @strategy = OmniAuth::Strategies::Developer.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/', 'rack.session' => {})
  end
  @strategy.call(@env)
end

duel 'passthrough: a long path' do
  once do
    @strategy = OmniAuth::Strategies::Developer.new(DuelHelper::APP)
    @env = DuelHelper.env_for("/#{(%w[Segment] * 250).join('/')}/", 'rack.session' => {})
  end
  @strategy.call(@env)
end

duel 'passthrough: another path under /auth' do
  once do
    @strategy = OmniAuth::Strategies::Developer.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/auth/failure?message=invalid_credentials&strategy=github', 'rack.session' => {})
  end
  @strategy.call(@env)
end

# A strategy with an other_phase, or with path lambdas, can't be passed
# through without a copy of it, so it takes the slower way, through
# #call!.

duel 'passthrough: a strategy with an other_phase' do
  once do
    @strategy = DuelHelper::OtherPhase.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/users/42/posts?page=2', 'rack.session' => {})
  end
  @strategy.call(@env)
end

duel 'passthrough: a strategy with a path lambda' do
  once do
    request_path = lambda { |env| env['PATH_INFO'].eql?('/sign_in/developer') }
    @strategy = OmniAuth::Strategies::Developer.new(DuelHelper::APP, :request_path => request_path)
    @env = DuelHelper.env_for('/users/42/posts?page=2', 'rack.session' => {})
  end
  @strategy.call(@env)
end
