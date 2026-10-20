require 'helper'

describe OmniAuth::Test::StrategyTestCase do
  include OmniAuth::Test::StrategyTestCase

  # Counts requests in the session, to show which session the strategy sees.
  let(:counter) do
    Class.new do
      def initialize(app, key = 'count')
        @app = app
        @key = key
      end

      def call(env)
        session = env['rack.session']
        session[@key] = session.fetch(@key, 0) + 1
        @app.call(env)
      end
    end
  end

  def strategy
    [OmniAuth::Strategies::Developer]
  end

  def text_response(body)
    [404, {'Content-Type' => 'text/plain'}, [body]]
  end

  describe '#strategy' do
    it 'must be defined by the including spec' do
      test_case = Object.new.extend(described_class)
      expect { test_case.strategy }.to raise_error(NotImplementedError, 'Including specs must define #strategy')
    end
  end

  describe '#app_response' do
    it 'is nil by default' do
      expect(Object.new.extend(described_class).app_response).to be_nil
    end
  end

  describe '#app' do
    it 'responds with true when the strategy set an auth hash' do
      params = {'name' => 'Ada', 'email' => 'ada@example.com'}
      env = Rack::MockRequest.env_for('/auth/developer/callback', :method => 'POST', :params => params)
      expect(app.call(env)).to eq(text_response('true'))
    end

    it 'responds with false when the strategy did not set an auth hash' do
      expect(app.call(Rack::MockRequest.env_for('/'))).to eq(text_response('false'))
    end

    it 'builds the app with Rack alone' do
      # The helper only requires rack and omniauth/test, so it can't rely on
      # OmniAuth::Builder having been loaded.
      hide_const('OmniAuth::Builder')
      expect(app.call(Rack::MockRequest.env_for('/'))).to eq(text_response('false'))
    end

    context 'with an app_response' do
      def app_response
        'custom body'
      end

      it 'responds with the app_response' do
        expect(app.call(Rack::MockRequest.env_for('/'))).to eq(text_response('custom body'))
      end
    end

    context 'with strategy arguments' do
      def strategy
        [counter, 'visits']
      end

      it 'passes them to the strategy' do
        get '/'
        expect(session).to eq('visits' => 1)
      end
    end

    context 'with a strategy that uses the session' do
      def strategy
        [counter]
      end

      it 'keeps the session between requests' do
        get '/'
        get '/'
        expect(session).to eq('count' => 2)
      end
    end
  end

  describe '#session' do
    def strategy
      [counter]
    end

    it 'returns the session of the last request' do
      get '/'
      expect(session).to be(last_request.env['rack.session'])
      expect(session).to eq('count' => 1)
    end

    context 'with an app that has no session' do
      def app
        lambda { |_env| [200, {}, []] }
      end

      it 'returns nil' do
        get '/'
        expect(session).to be_nil
      end
    end
  end
end
