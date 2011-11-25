require File.expand_path('../../spec_helper', __FILE__)

describe OmniAuth::Builder do
  describe '#provider' do
    it 'should translate a symbol to a constant' do
      OmniAuth::Strategies.should_receive(:const_get).with('MyStrategy').and_return(Class.new)
      OmniAuth::Builder.new(nil) do
        provider :my_strategy
      end
    end

    it 'should also just accept a class' do
      class ::ExampleClass; end

      lambda{ OmniAuth::Builder.new(nil) do
        provider ::ExampleClass
      end }.should_not raise_error
    end

    it "should raise a helpful LoadError messgae if it can't find the class" do
      expect {
        OmniAuth::Builder.new(nil) do
          provider :lorax
        end
      }.to raise_error(LoadError, "Could not find matching strategy for :lorax. You may need to install an additional gem (such as omniauth-lorax).")
    end
  end
end
