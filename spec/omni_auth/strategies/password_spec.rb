require File.dirname(__FILE__) + '/../../spec_helper'

describe OmniAuth::Strategies::Password do
  before(:each) do
    FakeAdapter.reset!
  end
  
  it do
    FakeAdapter.authenticate('mbleigh','dude').should be_false
    FakeAdapter.register('mbleigh','dude')
    FakeAdapter.authenticate('mbleigh','dude').should be_true
  end
end