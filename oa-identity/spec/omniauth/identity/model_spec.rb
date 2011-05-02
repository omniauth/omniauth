require 'spec_helper'

class ExampleModel
  include OmniAuth::Identity::Model
end

describe OmniAuth::Identity::Model do
  context 'Class Methods' do
    subject{ ExampleModel }

    describe '.locate' do
      it('should be abstract'){ lambda{ subject.locate('abc') }.should raise_error(NotImplementedError) }
    end

    describe '.authenticate' do
      it 'should call locate and then authenticate' do
        mocked_instance = mock('ExampleModel', :authenticate => 'abbadoo')
        subject.should_receive(:locate).with('example').and_return(mocked_instance)
        subject.authenticate('example','pass').should == 'abbadoo'
      end
    end
  end

  context 'Instance Methods' do
    subject{ ExampleModel.new }

    describe '#authenticate' do
      it('should be abstract'){ lambda{ subject.authenticate('abc') }.should raise_error(NotImplementedError) }
    end

    describe '#uid' do
      it 'should default to #id' do
        subject.should_receive(:respond_to?).with('id').and_return(true)
        subject.stub!(:id).and_return 'wakka-do'
        subject.uid.should == 'wakka-do'
      end

      it 'should raise NotImplementedError if #id is not defined' do
        lambda{ subject.uid }.should raise_error(NotImplementedError)
      end
    end

    describe '#auth_key' do
      it 'should default to #email' do
        subject.should_receive(:respond_to?).with('email').and_return(true)
        subject.stub!(:email).and_return('bob@bob.com')
        subject.auth_key.should == 'bob@bob.com'
      end

      it 'should use the class .auth_key' do
        subject.class.auth_key 'login'
        subject.stub!(:login).and_return 'bob'
        subject.auth_key.should == 'bob'
        subject.class.auth_key nil
      end

      it 'should raise a NotImplementedError if the auth_key method is not defined' do
        lambda{ subject.auth_key }.should raise_error(NotImplementedError)
      end
    end

    describe '#auth_key=' do
      it 'should default to setting email' do
        subject.should_receive(:respond_to?).with('email=').and_return(true)
        subject.should_receive(:email=).with 'abc'
        
        subject.auth_key = 'abc'
      end

      it 'should use a custom .auth_key if one is provided' do
        subject.class.auth_key 'login'
        subject.should_receive(:respond_to?).with('login=').and_return(true)
        subject.should_receive('login=').with('abc')

        subject.auth_key = 'abc'
      end

      it 'should raise a NotImplementedError if the autH_key method is not defined' do
        lambda{ subject.auth_key = 'broken' }.should raise_error(NotImplementedError)
      end
    end

    describe '#user_info' do
      it 'should include attributes that are set' do
        subject.stub!(:name).and_return('Bob Bobson')
        subject.stub!(:nickname).and_return('bob')

        subject.user_info.should == {
          'name' => 'Bob Bobson',
          'nickname' => 'bob'
        }
      end

      it 'should automatically set name off of first and last name' do
        subject.stub!(:first_name).and_return('Bob')
        subject.stub!(:last_name).and_return('Bobson')
        subject.user_info['name'].should == 'Bob Bobson'
      end

      it 'should automatically set name off of nickname' do
        subject.stub!(:nickname).and_return('bob')
        subject.user_info['name'] == 'bob'
      end

      it 'should not overwrite a provided name' do
        subject.stub!(:name).and_return('Awesome Dude')
        subject.stub!(:first_name).and_return('Frank')
        subject.user_info['name'].should == 'Awesome Dude'
      end
    end
  end
end
