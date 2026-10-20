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

  # The macros define examples, so call them from inside an example (rather
  # than while this file loads) on a group that is never registered with
  # RSpec.world, run that group, and report each example's description and
  # outcome: :passed, or the class of the error that failed it.
  def run_macro(env, macro, *args)
    request = Rack::Request.new(env)
    group = RSpec::Core::ExampleGroup.subclass(RSpec::Core::ExampleGroup, 'macro', [], []) do
      extend OmniAuth::Test::StrategyMacros

      define_method(:last_request) { request }
      public_send(macro, *args)
    end
    run_isolated(group)
    group.examples.map { |example| [example.description, outcome(example.execution_result)] }
  end

  def run_isolated(group)
    current_example = RSpec.current_example
    current_scope = RSpec.current_scope
    group.run
  ensure
    RSpec.current_example = current_example
    RSpec.current_scope = current_scope
  end

  def outcome(result)
    result.status == :passed ? :passed : result.exception.class
  end

  def not_met
    RSpec::Expectations::ExpectationNotMetError
  end

  def auth_env(auth)
    {'omniauth.auth' => auth}
  end

  describe '#sets_an_auth_hash' do
    it 'defines an example that passes when the auth hash is a Hash' do
      expect(run_macro(auth_env({}), :sets_an_auth_hash)).to eq([['sets an auth hash', :passed]])
    end

    it 'defines an example that passes when the auth hash is a Hash subclass' do
      expect(run_macro(auth_env(OmniAuth::AuthHash.new), :sets_an_auth_hash)).to eq([['sets an auth hash', :passed]])
    end

    it 'defines an example that fails when the auth hash is missing' do
      expect(run_macro({}, :sets_an_auth_hash)).to eq([['sets an auth hash', not_met]])
    end

    it 'defines an example that fails when the auth hash is not a Hash' do
      expect(run_macro(auth_env([]), :sets_an_auth_hash)).to eq([['sets an auth hash', not_met]])
    end
  end

  {
    :sets_provider_to => ['provider', 'sets the provider to'],
    :sets_uid_to => ['uid', 'sets the UID to'],
    :sets_user_info_to => ['user_info', 'sets the user_info to']
  }.each do |macro, (key, description)|
    describe "##{macro}" do
      it 'defines an example that passes when the value matches' do
        env = auth_env(key => 'expected')
        expect(run_macro(env, macro, 'expected')).to eq([["#{description} expected", :passed]])
      end

      it 'compares the value with ==' do
        expect(run_macro(auth_env(key => 1.0), macro, 1)).to eq([["#{description} 1", :passed]])
      end

      it 'defines an example that fails when the value differs' do
        env = auth_env(key => 'other')
        expect(run_macro(env, macro, 'expected')).to eq([["#{description} expected", not_met]])
      end

      it 'reads the value with a String key' do
        env = auth_env(key.to_sym => 'expected')
        expect(run_macro(env, macro, 'expected')).to eq([["#{description} expected", not_met]])
      end

      it 'treats a missing key as nil' do
        expect(run_macro(auth_env({}), macro, nil)).to eq([["#{description} ", :passed]])
      end

      it 'treats a missing auth hash as nil' do
        expect(run_macro({}, macro, nil)).to eq([["#{description} ", :passed]])
      end

      it 'defines an example that fails when the auth hash is missing and a value is expected' do
        expect(run_macro({}, macro, 'expected')).to eq([["#{description} expected", not_met]])
      end
    end
  end
end
