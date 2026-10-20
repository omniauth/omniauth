require 'helper'

describe OmniAuth do
  describe '.strategies' do
    it 'increases when a new strategy is made' do
      expect do
        class ExampleStrategy
          include OmniAuth::Strategy
        end
      end.to change(OmniAuth.strategies, :size).by(1)
      expect(OmniAuth.strategies.last).to eq(ExampleStrategy)
    end

    it 'starts as a memoized empty array' do
      old_strategies = OmniAuth.strategies
      OmniAuth.instance_variable_set(:@strategies, nil)
      strategies = OmniAuth.strategies
      expect(strategies).to eq([])
      expect(OmniAuth.strategies).to be(strategies)
    ensure
      OmniAuth.instance_variable_set(:@strategies, old_strategies)
    end
  end

  describe '.config' do
    it 'returns the configuration singleton' do
      expect(OmniAuth.config).to be(OmniAuth::Configuration.instance)
    end
  end

  describe '.configure' do
    it 'yields the configuration' do
      yielded = nil
      OmniAuth.configure { |config| yielded = config }
      expect(yielded).to be(OmniAuth.config)
    end

    it 'returns the block result' do
      expect(OmniAuth.configure { :configured }).to eq(:configured)
    end
  end

  describe '.logger' do
    it 'calls through to the configured logger' do
      allow(OmniAuth).to receive(:config).and_return(double(:logger => 'foo'))
      expect(OmniAuth.logger).to eq('foo')
    end
  end

  describe '.mock_auth_for' do
    before do
      @old_mock_auth = OmniAuth.config.mock_auth
      OmniAuth.config.mock_auth = @old_mock_auth.dup
    end

    after do
      OmniAuth.config.mock_auth = @old_mock_auth
    end

    it 'returns the mock for the provider' do
      OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
      expect(OmniAuth.mock_auth_for('twitter')).to eq(:invalid_credentials)
    end

    it 'falls back to the default mock' do
      expect(OmniAuth.mock_auth_for('twitter')).to be(OmniAuth.config.mock_auth[:default])
    end

    it 'returns nil without a provider or default mock' do
      OmniAuth.config.mock_auth = {}
      expect(OmniAuth.mock_auth_for('twitter')).to be_nil
    end
  end
end
