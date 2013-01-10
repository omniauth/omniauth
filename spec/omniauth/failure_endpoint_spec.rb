require 'helper'

describe OmniAuth::FailureEndpoint do
  subject{ OmniAuth::FailureEndpoint }

  context "development" do
    before do
      @rack_env = ENV['RACK_ENV']
      ENV['RACK_ENV'] = 'development'
    end

    it "raises out the error" do
      expect do
        subject.call('omniauth.error' => StandardError.new("Blah"))
      end.to raise_error(StandardError, "Blah")
    end

    it "raises out an OmniAuth::Error if no omniauth.error is set" do
      expect{ subject.call('omniauth.error.type' => 'example') }.to raise_error(OmniAuth::Error, "example")
    end

    after do
      ENV['RACK_ENV'] = @rack_env
    end
  end

  context "non-development" do
    let(:env){ {'omniauth.error.type' => 'invalid_request',
                'omniauth.error.strategy' => ExampleStrategy.new({}) } }

    it "is a redirect" do
      status, _, _ = *subject.call(env)
      expect(status).to eq(302)
    end

    it "includes the SCRIPT_NAME" do
      _, head, _ = *subject.call(env.merge('SCRIPT_NAME' => '/random'))
      expect(head['Location']).to eq('/random/auth/failure?message=invalid_request&strategy=test')
    end

    it "respects the configured path prefix" do
      OmniAuth.config.stub(:path_prefix => '/boo')
      _, head, _ = *subject.call(env)
      expect(head["Location"]).to eq('/boo/failure?message=invalid_request&strategy=test')
    end

    it "includes the origin (escaped) if one is provided" do
      env.merge! 'omniauth.origin' => '/origin-example'
      _, head, _ = *subject.call(env)
      expect(head['Location']).to be_include('&origin=%2Forigin-example')
    end
  end
end
