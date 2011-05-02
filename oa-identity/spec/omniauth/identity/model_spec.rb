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
