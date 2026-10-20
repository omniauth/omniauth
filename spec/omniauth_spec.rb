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
  end

  describe '.configure' do
    it 'yields the configuration' do
      OmniAuth.configure do |c|
        expect(c).to be_kind_of(OmniAuth::Configuration)
      end
    end
  end

  describe '.logger' do
    it 'calls through to the configured logger' do
      allow(OmniAuth).to receive(:config).and_return(double(:logger => 'foo'))
      expect(OmniAuth.logger).to eq('foo')
    end
  end
end
