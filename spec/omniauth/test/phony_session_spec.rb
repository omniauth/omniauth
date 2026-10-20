require 'helper'

describe OmniAuth::Test::PhonySession do
  subject(:phony) { described_class.new(inner) }

  let(:response) { [200, {}, ['OK']] }
  let(:seen) { [] }
  let(:inner) do
    calls = seen
    result = response
    lambda do |env|
      calls << env
      result
    end
  end

  describe '#call' do
    it 'calls the app with the env and returns its response' do
      env = {}
      expect(phony.call(env)).to be(response)
      expect(seen.size).to eq(1)
      expect(seen.first).to be(env)
    end

    it 'adds an empty session when the env has none' do
      env = {}
      phony.call(env)
      expect(env).to eq('rack.session' => {})
    end

    it 'adds an empty session when the env session is nil' do
      env = {'rack.session' => nil}
      phony.call(env)
      expect(env).to eq('rack.session' => {})
    end

    it 'uses the session already in the env' do
      session = {'user' => 'one'}
      env = {'rack.session' => session}
      phony.call(env)
      expect(env['rack.session']).to be(session)
    end

    it 'keeps the same session across requests' do
      first = {}
      phony.call(first)
      first['rack.session']['user'] = 'one'
      second = {'rack.session' => {'user' => 'two'}}
      phony.call(second)
      expect(second['rack.session']).to be(first['rack.session'])
      expect(second).to eq('rack.session' => {'user' => 'one'})
    end
  end
end
