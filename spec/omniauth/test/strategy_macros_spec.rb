require 'helper'

describe OmniAuth::Test::StrategyMacros, :type => :strategy do
  let(:app) do
    Rack::Builder.new do |b|
      b.freeze_app
      b.use Rack::Session::Cookie, :secret => SecureRandom.hex(32)
      b.use OmniAuth::Strategies::Developer
      b.run lambda { |_env| [200, {}, ['Not Found']] }
    end.to_app
  end

  context 'after a successful callback' do
    before { post '/auth/developer/callback', :name => 'Example User', :email => 'user@example.com' }

    sets_an_auth_hash
    sets_provider_to 'developer'
    sets_uid_to 'user@example.com'
    sets_user_info_to nil
  end

  context 'without an auth hash' do
    before { get '/' }

    sets_provider_to nil
    sets_uid_to nil
    sets_user_info_to nil
  end
end
