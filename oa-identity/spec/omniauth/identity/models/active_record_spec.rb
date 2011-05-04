require 'spec_helper'

describe(OmniAuth::Identity::Models::ActiveRecord, :db => true) do
  class TestIdentity < OmniAuth::Identity::Models::ActiveRecord
    auth_key :ham_sandwich
  end

  it 'should locate using the auth key using a where query' do
    TestIdentity.should_receive(:where).with('ham_sandwich' => 'open faced').and_return(['wakka'])
    TestIdentity.locate('open faced').should == 'wakka'
  end
  
  it 'should not use STI rules for its table name' do
    TestIdentity.table_name.should == 'test_identities'
  end
end
