require 'helper'

# The top-level describe is OmniAuth::Strategy rather than
# OmniAuth::Strategy::ClassMethods so mutant keeps selecting every
# OmniAuth::Strategy example for the ClassMethods subjects.
describe OmniAuth::Strategy, 'class methods' do
  subject(:strategy_class) do
    c = Class.new
    c.send(:include, OmniAuth::Strategy)
  end

  context 'configure' do
    it 'leaves the default options alone when given neither options nor a block' do
      strategy_class.configure
      expect(strategy_class.default_options).to eq('setup' => false, 'skip_info' => false, 'origin_param' => 'origin')
    end
  end

  context 'default_dispatch?' do
    it 'looks the dispatch methods up once per class' do
      expect(strategy_class).to receive(:instance_method).exactly(described_class::ClassMethods::DISPATCH_METHODS.size).times.and_call_original
      expect(strategy_class.default_dispatch?).to be(true)
      expect(strategy_class.default_dispatch?).to be(true)
    end

    it 'remembers a false answer too' do
      overriding = Class.new(strategy_class) { define_method(:call!) { |env| super(env) } }
      expect(overriding.default_dispatch?).to be(false)
      expect(overriding).not_to receive(:instance_method)
      expect(overriding.default_dispatch?).to be(false)
    end
  end

  context 'args' do
    it 'returns nil when setting args' do
      expect(strategy_class.args(%i[abc])).to be_nil
    end

    it 'keeps an Array subclass as the list of args' do
      strategy_class.args(Class.new(Array).new(%i[abc def]))
      expect(strategy_class.args).to eq(%i[abc def])
    end
  end

  context 'fetcher stacks' do
    %w[uid info credentials extra].each do |fetcher|
      it "runs the #{fetcher} blocks with the strategy instance as self" do
        strategy_class.send(fetcher) { options[:name] }
        expect(strategy_class.send("#{fetcher}_stack", strategy_class.new(nil, :name => 'mine'))).to eq(%w[mine])
      end
    end
  end
end
