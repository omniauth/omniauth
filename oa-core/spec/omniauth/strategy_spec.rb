require 'spec_helper'

class ExampleStrategy
  include OmniAuth::Strategy
  def call(env); self.call!(env) end
  def request_phase
    raise "Request Phase"
  end
  def callback_phase
    raise "Callback Phase"
  end
end

describe OmniAuth::Strategy do
  let(:app){ lambda{|env| [200, {}, ['Awesome']]}}
  describe '#initialize' do
    context 'options extraction' do
      it 'should be the last argument if the last argument is a Hash' do
        ExampleStrategy.new(app, 'test', :abc => 123).options[:abc].should == 123
      end
    
      it 'should be a blank hash if none are provided' do
        ExampleStrategy.new(app, 'test').options.should == {}
      end
    end
  end
  
  describe '#call' do
    let(:strategy){ ExampleStrategy.new(app, 'test', @options) }
    
    context 'default paths' do
      it 'should use the default request path' do
        lambda{ strategy.call({'PATH_INFO' => '/auth/test'}) }.should raise_error("Request Phase")
      end
      
      it 'should use the default callback path' do
        lambda{ strategy.call({'PATH_INFO' => '/auth/test/callback'}) }.should raise_error("Callback Phase")
      end
    end
    
    context 'custom paths' do
      it 'should use a custom request_path if one is provided' do
        @options = {:request_path => '/awesome'}
        lambda{ strategy.call({'PATH_INFO' => '/awesome'}) }.should raise_error("Request Phase")
      end
    
      it 'should use a custom callback_path if one is provided' do
        @options = {:callback_path => '/radical'}
        lambda{ strategy.call({'PATH_INFO' => '/radical'}) }.should raise_error("Callback Phase")
      end
    end
    
    context 'custom prefix' do
      before do
        @options = {:path_prefix => '/wowzers'}
      end
      
      it 'should use a custom prefix for request' do
        lambda{ strategy.call({'PATH_INFO' => '/wowzers/test'}) }.should raise_error("Request Phase")
      end
      
      it 'should use a custom prefix for callback' do
        lambda{ strategy.call({'PATH_INFO' => '/wowzers/test/callback'}) }.should raise_error("Callback Phase")
      end
    end
  end
end