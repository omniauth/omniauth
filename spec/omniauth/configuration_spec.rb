require 'helper'

describe OmniAuth::Configuration do
  describe '.defaults' do
    before do
      @old_defaults = described_class.instance_variable_get(:@defaults)
      described_class.instance_variable_set(:@defaults, nil)
    end

    after do
      described_class.instance_variable_set(:@defaults, @old_defaults)
    end

    it 'is a hash of default configuration' do
      defaults = described_class.defaults
      expect(defaults.reject { |key, _| key == :logger }).to eq(
        :camelizations => {},
        :path_prefix => '/auth',
        :on_failure => OmniAuth::FailureEndpoint,
        :failure_raise_out_environments => ['development'],
        :request_validation_phase => OmniAuth::AuthenticityTokenProtection,
        :before_request_phase => nil,
        :after_request_phase => nil,
        :allowed_hosts => nil,
        :before_callback_phase => nil,
        :before_options_phase => nil,
        :form_css => OmniAuth::Form::DEFAULT_CSS,
        :test_mode => false,
        :allowed_request_methods => [:post],
        :mock_auth => {:default => {'provider' => 'default', 'uid' => '1234', 'info' => {'name' => 'Example User'}}},
        :silence_get_warning => false
      )
      expect(defaults[:mock_auth][:default]).to be_an_instance_of(OmniAuth::AuthHash)
      expect(defaults[:logger]).to be_an_instance_of(Logger)
      expect(defaults[:logger].progname).to eq('omniauth')
    end

    it 'is memoized' do
      expect(described_class.defaults).to be(described_class.defaults)
    end
  end

  describe '.default_logger' do
    it 'logs to stdout as omniauth' do
      expect { described_class.default_logger.info('hello') }.to output(/INFO -- omniauth: hello$/).to_stdout
    end
  end

  describe '#initialize' do
    it 'applies every default' do
      config = described_class.send(:new)
      described_class.defaults.each_pair do |key, value|
        expect(config.public_send(key)).to be(value)
      end
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
    @old_mock_auth                = OmniAuth.config.mock_auth
    @old_camelizations            = OmniAuth.config.camelizations
    OmniAuth.config.mock_auth     = @old_mock_auth.dup
    OmniAuth.config.camelizations = @old_camelizations.dup
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
      config.mock_auth                = @old_mock_auth
      config.camelizations            = @old_camelizations
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

  it 'is able to set hook on after_request_phase' do
    OmniAuth.configure do |config|
      config.after_request_phase do
        'byebye'
      end
    end
    expect(OmniAuth.config.after_request_phase.call).to eq('byebye')
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

  describe '#add_mock' do
    it 'stores and returns the merged mock under the provider symbol' do
      mock = OmniAuth.config.add_mock('twitter', :uid => '42')
      expect(mock).to eq('provider' => 'twitter', 'uid' => '42', 'info' => {'name' => 'Example User'})
      expect(mock).to be_an_instance_of(OmniAuth::AuthHash)
      expect(OmniAuth.config.mock_auth[:twitter]).to be(mock)
    end

    it 'stores the provider name as a string' do
      expect(OmniAuth.config.add_mock(:github)['provider']).to eq('github')
    end

    it 'uses the default mock when no auth hash is given' do
      expect(OmniAuth.config.add_mock(:github)).to eq('provider' => 'github', 'uid' => '1234', 'info' => {'name' => 'Example User'})
    end

    it 'stringifies keys when the default mock is a plain Hash' do
      OmniAuth.config.mock_auth[:default] = {'provider' => 'default', 'uid' => '1234'}
      info = Class.new(Hash).new
      info[:name] = 'Joe'
      mock = OmniAuth.config.add_mock(:facebook, :uid => '5', :info => info, :extra => {:raw => 'data'})
      expect(mock).to eq('provider' => 'facebook', 'uid' => '5', 'info' => {'name' => 'Joe'}, 'extra' => {'raw' => 'data'})
    end
  end

  describe '#add_camelization' do
    it 'stores the camelization with string keys and values' do
      expect(OmniAuth.config.add_camelization(:oauth, :OAuth)).to eq('OAuth')
      expect(OmniAuth.config.camelizations).to eq(@old_camelizations.merge('oauth' => 'OAuth'))
    end
  end
end
