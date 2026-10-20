require 'helper'

RSpec.describe OmniAuth::KeyStore do
  around(:each) do |example|
    original_logger = Hashie.logger
    Hashie.logger = logger
    example.run
    Hashie.logger = original_logger
  end

  let(:logger) { double('Logger') }

  it 'does not warn when a key overrides a Mash method' do
    expect(logger).not_to receive(:warn)
    expect(logger).not_to receive(:info)
    expect(OmniAuth::KeyStore.new(:count => 1234)['count']).to eq(1234)
  end

  it 'does not warn after override_logging is called again' do
    OmniAuth::KeyStore.override_logging
    expect(logger).not_to receive(:warn)
    OmniAuth::KeyStore.new(:zip => '12345')
  end

  it 'disables warnings on a subclass that re-enabled them' do
    subclass = Class.new(OmniAuth::KeyStore)
    subclass.instance_variable_set(:@disable_warnings, false)
    allow(logger).to receive(:warn)

    subclass.new(:count => 1)
    subclass.override_logging
    subclass.new(:zip => '12345')

    expect(logger).to have_received(:warn).once
  end
end
