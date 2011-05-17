require 'spec_helper'

describe OmniAuth::AuthHash do
  subject{ OmniAuth::AuthHash.new }
  it 'should convert a supplied user_info key into a UserInfo object' do
    subject.user_info = {:name => 'Awesome'}
    subject.user_info.should be_kind_of(OmniAuth::AuthHash::UserInfo)
    subject.user_info.name.should == 'Awesome'
  end

  describe '#valid?' do
    subject{ OmniAuth::AuthHash.new(:uid => '123', :provider => 'example', :user_info => {:name => 'Steven'}) }

    it 'should be valid with the right parameters' do
      subject.should be_valid
    end

    it 'should require a uid' do
      subject.uid = nil
      subject.should_not be_valid
    end

    it 'should require a provider' do
      subject.provider = nil
      subject.should_not be_valid
    end

    it 'should require a name in the user info hash' do
      subject.user_info.name = nil
      subject.should_not be_valid?
    end
  end

  describe OmniAuth::AuthHash::UserInfo do
    describe '#valid?' do
      it 'should be valid if there is a name' do
        OmniAuth::AuthHash::UserInfo.new(:name => 'Awesome').should be_valid
      end
    end

    describe '#name' do
      subject{ OmniAuth::AuthHash::UserInfo.new(
        :name => 'Phillip J. Fry',
        :first_name => 'Phillip',
        :last_name => 'Fry',
        :nickname => 'meatbag',
        :email => 'fry@planetexpress.com'
      )}

      it 'should default to the name key' do
        subject.name.should == 'Phillip J. Fry'
      end

      it 'should fall back to go to first_name last_name concatenation' do
        subject.name = nil
        subject.name.should == 'Phillip Fry'
      end

      it 'should display only a first or last name if only that is available' do
        subject.name = nil
        subject.first_name = nil
        subject.name.should == 'Fry'
      end

      it 'should display the nickname if no name, first, or last is available' do
        %w(name first_name last_name).each{|k| subject[k] = nil}
        subject.name.should == 'meatbag'
      end

      it 'should display the email if no name, first, last, or nick is available' do
        %w(name first_name last_name nickname).each{|k| subject[k] = nil}
        subject.name.should == 'fry@planetexpress.com'
      end
    end
  end
end
