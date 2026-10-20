require 'helper'

describe OmniAuth::FailureEndpoint do
  subject { OmniAuth::FailureEndpoint }

  context 'raise-out environment' do
    before do
      @rack_env = ENV.fetch('RACK_ENV', nil)
      ENV['RACK_ENV'] = 'test'

      @default = OmniAuth.config.failure_raise_out_environments
      OmniAuth.config.failure_raise_out_environments = ['test']
    end

    it 'raises out the error' do
      expect do
        subject.call('omniauth.error' => StandardError.new('Blah'))
      end.to raise_error(StandardError, 'Blah')
    end

    it 'raises out an OmniAuth::Error if no omniauth.error is set' do
      expect { subject.call('omniauth.error.type' => 'example') }.to raise_error(OmniAuth::Error, 'example')
    end

    it 'raises out a bare OmniAuth::Error if no error type is set either' do
      expect { subject.call({}) }.to raise_error(OmniAuth::Error, 'OmniAuth::Error')
    end

    after do
      ENV['RACK_ENV'] = @rack_env
      OmniAuth.config.failure_raise_out_environments = @default
    end
  end

  context 'with RACK_ENV unset' do
    before do
      @rack_env = ENV.delete('RACK_ENV')
      @default = OmniAuth.config.failure_raise_out_environments
    end

    after do
      ENV['RACK_ENV'] = @rack_env
      OmniAuth.config.failure_raise_out_environments = @default
    end

    it 'raises out when the blank environment is a raise-out environment' do
      OmniAuth.config.failure_raise_out_environments = ['']

      expect { subject.call('omniauth.error.type' => 'example') }.to raise_error(OmniAuth::Error, 'example')
    end

    it 'redirects otherwise' do
      OmniAuth.config.failure_raise_out_environments = ['development']

      expect(subject.call('omniauth.error.type' => 'example')[0]).to eq(302)
    end
  end

  context 'non-raise-out environment' do
    def location(response)
      expect(response).to be_instance_of(Array)
      status, headers, body = response
      expect(status).to eq(302)
      expect(body.to_enum(:each).to_a).to eq(['302 Moved'])
      headers = headers.to_h.transform_keys(&:downcase)
      expect(headers.keys).to eq(['location'])
      headers['location']
    end

    it 'redirects to the global failure path without a strategy' do
      expect(location(subject.call('omniauth.error.type' => 'invalid_request'))).to eq('/auth/failure?message=invalid_request')
    end

    it 'ignores a nil strategy and origin' do
      response = subject.call('omniauth.error.type' => 'invalid_request', 'omniauth.error.strategy' => nil, 'omniauth.origin' => nil)

      expect(location(response)).to eq('/auth/failure?message=invalid_request')
    end

    it 'uses the globally configured path prefix without a strategy' do
      allow(OmniAuth.config).to receive(:path_prefix).and_return('/boo')

      expect(location(subject.call('omniauth.error.type' => 'invalid_request'))).to eq('/boo/failure?message=invalid_request')
    end

    it 'redirects with an empty message if no error type is set' do
      expect(location(subject.call({}))).to eq('/auth/failure?message=')
    end

    it 'redirects with the strategy, origin and SCRIPT_NAME' do
      response = subject.call(env.merge('SCRIPT_NAME' => '/app', 'omniauth.origin' => '/origin-example'))

      expect(location(response)).to eq('/app/auth/failure?message=invalid_request&origin=%2Forigin-example&strategy=test')
    end

    it 'returns empty query params without a strategy or origin' do
      endpoint = subject.new({})

      expect(endpoint.strategy_name_query_param).to eq('')
      expect(endpoint.origin_query_param).to eq('')
    end

    let(:env) do
      {'omniauth.error.type' => 'invalid_request', 'omniauth.error.strategy' => ExampleStrategy.new({})}
    end

    it 'is a redirect' do
      status, = *subject.call(env)
      expect(status).to eq(302)
    end

    it 'includes the SCRIPT_NAME' do
      _, head, = *subject.call(env.merge('SCRIPT_NAME' => '/random'))
      expect(head['Location']).to eq('/random/auth/failure?message=invalid_request&strategy=test')
    end

    it 'respects the globally configured path prefix' do
      allow(OmniAuth.config).to receive(:path_prefix).and_return('/boo')
      _, head, = *subject.call(env)
      expect(head['Location']).to eq('/boo/failure?message=invalid_request&strategy=test')
    end

    it 'respects the custom path prefix configured on the strategy' do
      env['omniauth.error.strategy'] = ExampleStrategy.new({}, :path_prefix => '/some/custom/path')
      _, head, = *subject.call(env)
      expect(head['Location']).to eq('/some/custom/path/failure?message=invalid_request&strategy=test')
    end

    it 'includes the origin (escaped) if one is provided' do
      env['omniauth.origin'] = '/origin-example'
      _, head, = *subject.call(env)
      expect(head['Location']).to be_include('&origin=%2Forigin-example')
    end

    it 'escapes the message key' do
      _, head = *subject.call(env.merge('omniauth.error.type' => 'Connection refused!'))
      expect(head['Location']).to be_include('message=Connection+refused%21')
    end
  end
end
