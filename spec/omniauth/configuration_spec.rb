require 'helper'

describe OmniAuth::Configuration do
  describe '.defaults' do
    it 'is a hash of default configuration' do
      expect(described_class.defaults).to be_kind_of(Hash)
    end
  end

  before do
    @old_path_prefix              = OmniAuth.config.path_prefix
    @old_on_failure               = OmniAuth.config.on_failure
    @old_before_callback_phase    = OmniAuth.config.before_callback_phase
    @old_before_options_phase     = OmniAuth.config.before_options_phase
    @old_before_request_phase     = OmniAuth.config.before_request_phase
    @old_after_request_phase      = OmniAuth.config.after_request_phase
    @old_request_validation_phase = OmniAuth.config.request_validation_phase
  end

  after do
    OmniAuth.configure do |config|
      config.path_prefix              = @old_path_prefix
      config.on_failure               = @old_on_failure
      config.before_callback_phase    = @old_before_callback_phase
      config.before_options_phase     = @old_before_options_phase
      config.before_request_phase     = @old_before_request_phase
      config.after_request_phase      = @old_after_request_phase
      config.request_validation_phase = @old_request_validation_phase
    end
  end

  it 'is able to set the path' do
    OmniAuth.configure do |config|
      config.path_prefix = '/awesome'
    end

    expect(OmniAuth.config.path_prefix).to eq('/awesome')
  end

  it 'is able to set the on_failure rack app' do
    OmniAuth.configure do |config|
      config.on_failure do
        'yoyo'
      end
    end

    expect(OmniAuth.config.on_failure.call).to eq('yoyo')
  end

  it 'is able to set hook on option_call' do
    OmniAuth.configure do |config|
      config.before_options_phase do
        'yoyo'
      end
    end
    expect(OmniAuth.config.before_options_phase.call).to eq('yoyo')
  end

  it 'is able to set hook on request_call' do
    OmniAuth.configure do |config|
      config.before_request_phase do
        'heyhey'
      end
    end
    expect(OmniAuth.config.before_request_phase.call).to eq('heyhey')
  end

  it 'is able to set hook on callback_call' do
    OmniAuth.configure do |config|
      config.before_callback_phase do
        'heyhey'
      end
    end
    expect(OmniAuth.config.before_callback_phase.call).to eq('heyhey')
  end

  it 'is able to set request_validation_phase' do
    OmniAuth.configure do |config|
      config.request_validation_phase do
        'validated'
      end
    end
    expect(OmniAuth.config.request_validation_phase.call).to eq('validated')
  end

  describe 'mock auth' do
    before do
      @auth_hash = {:uid => '12345', :info => {:name => 'Joe', :email => 'joe@example.com'}}
      @original_auth_hash = @auth_hash.dup

      OmniAuth.config.add_mock(:facebook, @auth_hash)
    end
    it 'default is AuthHash' do
      OmniAuth.configure do |config|
        expect(config.mock_auth[:default]).to be_kind_of(OmniAuth::AuthHash)
      end
    end
    it 'facebook is AuthHash' do
      OmniAuth.configure do |config|
        expect(config.mock_auth[:facebook]).to be_kind_of(OmniAuth::AuthHash)
      end
    end
    it 'sets facebook attributes' do
      OmniAuth.configure do |config|
        expect(config.mock_auth[:facebook].uid).to eq('12345')
        expect(config.mock_auth[:facebook].info.name).to eq('Joe')
        expect(config.mock_auth[:facebook].info.email).to eq('joe@example.com')
      end
    end
    it 'does not mutate given auth hash' do
      OmniAuth.configure do
        expect(@auth_hash).to eq @original_auth_hash
      end
    end
  end
end
