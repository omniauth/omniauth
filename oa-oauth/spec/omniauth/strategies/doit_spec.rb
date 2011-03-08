require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OmniAuth::Strategies::Doit do
  it_should_behave_like 'an oauth strategy'
  
  it 'should use the authenticate (sign in) path by default' do
    s = strategy_class.new(app, 'abc', 'def')
    s.consumer.options[:authorize_path].should == '/oauth/authenticate'
  end
  
  it 'should use the authorize path if :sign_in is false' do
    s = strategy_class.new(app, 'abc', 'def', :sign_in => false)
    s.consumer.options[:authorize_path].should == '/oauth/authorize'
  end
end