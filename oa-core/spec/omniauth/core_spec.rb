require File.dirname(__FILE__) + '/../spec_helper'

describe OmniAuth do
  context 'configuration' do
    it 'should be callable from .configure' do
      OmniAuth.configure do |c|
        c.should be_kind_of(OmniAuth::Configuration)
      end
    end
    
    it 'should be able to set the path' do
      OmniAuth.configure do |config|
        config.path_prefix = '/awesome'
      end
      
      OmniAuth.config.path_prefix.should == '/awesome'
    end
    
    it 'should be able to set the on_failure rack app' do
      OmniAuth.configure do |config|
        config.on_failure do
          'yoyo'
        end
      end
      
      OmniAuth.config.on_failure.call.should == 'yoyo'
    end
  end
  
  describe '::Utils' do
    describe '.deep_merge' do
      it 'should combine hashes' do
        OmniAuth::Utils.deep_merge({'abc' => {'def' => 123}}, {'abc' => {'foo' => 'bar'}}).should == {
          'abc' => {'def' => 123, 'foo' => 'bar'}
        }
      end
    end
    
    describe '.camelize' do
      it 'should work on normal cases' do
        {
          'some_word' => 'SomeWord',
          'AnotherWord' => 'AnotherWord',
          'one' => 'One',
          'three_words_now' => 'ThreeWordsNow'
        }.each_pair{ |k,v| OmniAuth::Utils.camelize(k).should == v }
      end
      
      it 'should work in special cases' do
        {
          'oauth' => "OAuth",
          'openid' => 'OpenID',
          'open_id' => 'OpenID'
        }.each_pair{ |k,v| OmniAuth::Utils.camelize(k).should == v}
      end
    end
  end
end