require 'helper'

describe OmniAuth::AuthBuilder do

  let(:app) { proc { [204, {}, ['']] } }

  describe '#provider' do
    it 'translates a symbol to a constant' do
      expect(OmniAuth::Strategies).to receive(:const_get).with('MyStrategy', false).and_return(Class.new)
      OmniAuth::AuthBuilder.new(app) do
        provider :my_strategy
      end
    end

    it 'accepts a class' do
      class ExampleClass; end

      expect do
        OmniAuth::AuthBuilder.new(app) do
          provider ::ExampleClass
        end
      end.not_to raise_error
    end

    it "raises a helpful LoadError message if it can't find the class" do
      expect do
        OmniAuth::AuthBuilder.new(app) do
          provider :lorax
        end
      end.to raise_error(LoadError, 'Could not find matching strategy for :lorax. You may need to install an additional gem (such as omniauth-lorax).')
    end

    it "doesn't translate a symbol to a top-level constant" do
      class MyStrategy; end

      expect do
        OmniAuth::AuthBuilder.new(app) do
          provider :my_strategy
        end
      end.to raise_error(LoadError, 'Could not find matching strategy for :my_strategy. You may need to install an additional gem (such as omniauth-my_strategy).')
    end
  end

  describe '#options' do
    it 'merges provided options in' do
      k = Class.new
      b = OmniAuth::AuthBuilder.new(app)
      expect(b).to receive(:use).with(k, :foo => 'bar', :baz => 'tik')

      b.options :foo => 'bar'
      b.provider k, :baz => 'tik'
    end

    it 'adds an argument if no options are provided' do
      k = Class.new
      b = OmniAuth::AuthBuilder.new(app)
      expect(b).to receive(:use).with(k, :foo => 'bar')

      b.options :foo => 'bar'
      b.provider k
    end
  end

  describe '#on_failure' do
    it 'passes the block to the config' do
      prok = proc {}

      with_config_reset(:on_failure) do
        OmniAuth::AuthBuilder.new(app).on_failure(&prok)

        expect(OmniAuth.config.on_failure).to eq(prok)
      end
    end
  end

  describe '#before_options_phase' do
    it 'passes the block to the config' do
      prok = proc {}

      with_config_reset(:before_options_phase) do
        OmniAuth::AuthBuilder.new(app).before_options_phase(&prok)

        expect(OmniAuth.config.before_options_phase).to eq(prok)
      end
    end
  end

  describe '#before_request_phase' do
    it 'passes the block to the config' do
      prok = proc {}

      with_config_reset(:before_request_phase) do
        OmniAuth::AuthBuilder.new(app).before_request_phase(&prok)

        expect(OmniAuth.config.before_request_phase).to eq(prok)
      end
    end
  end

  describe '#before_callback_phase' do
    it 'passes the block to the config' do
      prok = proc {}

      with_config_reset(:before_callback_phase) do
        OmniAuth::AuthBuilder.new(app).before_callback_phase(&prok)

        expect(OmniAuth.config.before_callback_phase).to eq(prok)
      end
    end
  end

  describe '#configure' do
    it 'passes the block to the config' do
      prok = proc {}
      allow(OmniAuth).to receive(:configure).and_call_original

      OmniAuth::AuthBuilder.new(app).configure(&prok)

      expect(OmniAuth).to have_received(:configure) do |&block|
        expect(block).to eq(prok)
      end
    end
  end

  describe '#call' do
    it 'passes env to to_app.call' do
      app = lambda { |env| [200, {}, [env['CUSTOM_ENV_VALUE']]] }
      builder = OmniAuth::AuthBuilder.new(app)
      env = {'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/some/path', 'CUSTOM_ENV_VALUE' => 'VALUE'}

      expect(builder.call(env)).to eq([200, {}, ['VALUE']])
    end
  end

  def with_config_reset(option)
    old_config = OmniAuth.config.send(option)
    yield
    OmniAuth.config.send("#{option}=", old_config)
  end
end
