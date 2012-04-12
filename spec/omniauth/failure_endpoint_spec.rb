require 'spec_helper'

describe OmniAuth::FailureEndpoint do
  subject{ OmniAuth::FailureEndpoint }

  context 'development' do
    before do
      @rack_env = ENV['RACK_ENV']
      ENV['RACK_ENV'] = 'development'
    end

    it 'should raise out the error' do
      expect do
        subject.call('omniauth.error' => StandardError.new("Blah"))
      end.to raise_error(StandardError, "Blah")
    end

    it 'should raise out an OmniAuth::Error if no omniauth.error is set' do
      expect{ subject.call('omniauth.error.type' => 'example') }.to raise_error(OmniAuth::Error, "example")
    end

    after do
      ENV['RACK_ENV'] = @rack_env
    end
  end

  context 'non-development' do
    let(:env){ {'omniauth.error.type' => 'invalid_request',
                'omniauth.error.strategy' => ExampleStrategy.new({}) } }

    it 'should be a redirect' do
      status, head, body = *subject.call(env)
      status.should == 302
    end

    it 'should include the SCRIPT_NAME' do
      status, head, body = *subject.call(env.merge('SCRIPT_NAME' => '/random'))
      head['Location'].should == '/random/auth/failure?message=invalid_request&strategy=test'
    end

    it 'should respect configured path prefix' do
      OmniAuth.config.stub(:path_prefix => '/boo')
      status, head, body = *subject.call(env)
      head["Location"].should == '/boo/failure?message=invalid_request&strategy=test'
    end

    it 'should include the origin (escaped) if one is provided' do
      env.merge! 'omniauth.origin' => '/origin-example'
      status, head, body = *subject.call(env)
      head['Location'].should be_include('&origin=%2Forigin-example')
    end
  end
end