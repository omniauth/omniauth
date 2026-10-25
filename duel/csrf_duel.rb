require_relative 'duel_helper'

# The request validation phase that checks the request phase's
# authenticity token against the session's. Rack caches the parsed params
# in the env, so they're parsed once, untimed, and these time the check
# itself.

duel 'csrf: a valid token in the form' do
  once do
    session, token = DuelHelper.csrf_session
    @env = DuelHelper.env_for('/auth/developer', :method => 'POST', :params => {'authenticity_token' => token}, 'rack.session' => session)
    OmniAuth::AuthenticityTokenProtection.call(@env)
  end
  OmniAuth::AuthenticityTokenProtection.call(@env)
end

duel 'csrf: a valid token in a header' do
  once do
    session, token = DuelHelper.csrf_session
    @env = DuelHelper.env_for('/auth/developer', :method => 'POST', 'HTTP_X_CSRF_TOKEN' => token, 'rack.session' => session)
    OmniAuth::AuthenticityTokenProtection.call(@env)
  end
  OmniAuth::AuthenticityTokenProtection.call(@env)
end
