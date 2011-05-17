require 'spec_helper'

class HasTheMethod
  def self.has_secure_password; end
end

class DoesNotHaveTheMethod
end

describe OmniAuth::Identity::SecurePassword do
  it 'should extend with the class methods if it does not have the method' do
    DoesNotHaveTheMethod.should_receive(:extend).with(OmniAuth::Identity::SecurePassword::ClassMethods)
    DoesNotHaveTheMethod.send(:include, OmniAuth::Identity::SecurePassword)
  end

  it 'should not extend if the method is already defined' do
    HasTheMethod.should_not_receive(:extend)
    HasTheMethod.send(:include, OmniAuth::Identity::SecurePassword)
  end

  it 'should respond to has_secure_password afterwards' do
    [HasTheMethod,DoesNotHaveTheMethod].each do |klass|
      klass.send(:include, OmniAuth::Identity::SecurePassword)
      klass.should be_respond_to(:has_secure_password)
    end
  end
end
