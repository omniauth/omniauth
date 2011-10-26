require 'spec_helper'

describe OmniAuth::Form do
  describe '.build' do
    it 'should yield the instance when called with a block and argument' do
      OmniAuth::Form.build{|f| f.should be_kind_of(OmniAuth::Form)}
    end

    it 'should evaluate in the instance when called with a block and no argument' do
      OmniAuth::Form.build{ self.class.should == OmniAuth::Form }
    end
  end

  describe '#initialize' do
    it 'the :url option should supply to the form that is built' do
      OmniAuth::Form.new(:url => '/awesome').to_html.should be_include("action='/awesome'")
    end

    it 'the :title option should set an H1 tag' do
      OmniAuth::Form.new(:title => 'Something Cool').to_html.should be_include('<h1>Something Cool</h1>')
    end
  end
end
