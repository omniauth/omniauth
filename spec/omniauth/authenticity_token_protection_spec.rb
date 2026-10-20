require 'helper'

describe OmniAuth::AuthenticityTokenProtection do
  let(:token) { Rack::Protection::AuthenticityToken.random_token }
  let(:session) { {:csrf => token} }

  def env_for(method, params = {})
    Rack::MockRequest.env_for('/auth/test', :method => method, :params => params).merge('rack.session' => session)
  end

  before { allow(OmniAuth.logger).to receive(:warn) }

  describe '.call' do
    it 'accepts a request with a matching authenticity token' do
      expect(described_class.call(env_for('POST', 'authenticity_token' => token))).to be_nil
      expect(OmniAuth.logger).not_to have_received(:warn)
    end

    it 'accepts a safe request without a token' do
      expect(described_class.call(env_for('GET'))).to be_nil
    end

    it 'raises an AuthenticityError and logs a warning for a request without a token' do
      expect { described_class.call(env_for('POST')) }.to raise_error(OmniAuth::AuthenticityError, 'Forbidden')
      expect(OmniAuth.logger).to have_received(:warn).with('Attack prevented by OmniAuth::AuthenticityTokenProtection').once
    end
  end

  describe '#call' do
    it 'validates the request like #call!' do
      protection = described_class.new

      expect(protection.call(env_for('POST', 'authenticity_token' => token))).to be_nil
      expect { protection.call(env_for('POST')) }.to raise_error(OmniAuth::AuthenticityError, 'Forbidden')
    end
  end

  describe '#call!' do
    it 'returns nil for an accepted request' do
      expect(described_class.new.call!(env_for('POST', 'authenticity_token' => token))).to be_nil
    end

    it 'raises an AuthenticityError with the configured message' do
      protection = described_class.new(:message => 'Invalid token')

      expect { protection.call!(env_for('POST')) }.to raise_error(OmniAuth::AuthenticityError, 'Invalid token')
    end

    it 'instruments a rejected request' do
      instrumenter = double('Instrumenter')
      env = env_for('POST')
      allow(instrumenter).to receive(:instrument)

      expect { described_class.new(:instrumenter => instrumenter).call!(env) }.to raise_error(OmniAuth::AuthenticityError)
      expect(instrumenter).to have_received(:instrument).with('rack.protection', env)
      expect(env['rack.protection.attack']).to eq('authenticitytokenprotection')
    end

    it 'does not instrument an accepted request' do
      instrumenter = double('Instrumenter')

      described_class.new(:instrumenter => instrumenter).call!(env_for('GET'))
    end

    it 'raises an AuthenticityError and logs a warning when reacting with #deny' do
      protection = described_class.new(:reaction => :deny, :message => 'Invalid token')

      expect { protection.call!(env_for('POST')) }.to raise_error(OmniAuth::AuthenticityError, 'Invalid token')
      expect(OmniAuth.logger).to have_received(:warn).with('Attack prevented by OmniAuth::AuthenticityTokenProtection').once
    end

    it 'returns the result of a custom reaction' do
      protection = Class.new(described_class) do
        def reject(env)
          [403, {}, [env['PATH_INFO']]]
        end
      end.new(:reaction => :reject)

      expect(protection.call!(env_for('POST'))).to eq([403, {}, ['/auth/test']])
    end
  end
end
