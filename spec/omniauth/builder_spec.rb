require 'helper'

describe OmniAuth::Builder do
  describe '#call' do
    it 'passes env to to_app.call' do
      app = lambda { |env| [200, {}, env['CUSTOM_ENV_VALUE']] }
      builder = OmniAuth::Builder.new(app)
      env = {'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/some/path', 'CUSTOM_ENV_VALUE' => 'VALUE'}

      expect(builder.call(env)).to eq([200, {}, 'VALUE'])
    end
  end
end
