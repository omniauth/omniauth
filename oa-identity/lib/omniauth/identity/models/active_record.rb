require 'active_record'

module OmniAuth
  module Identity
    module Models
      class ActiveRecord < ::ActiveRecord::Base
        include OmniAuth::Identity::Model
        include OmniAuth::Identity::SecurePassword

        self.abstract_class = true
        has_secure_password
       
        def self.auth_key=(key)
          super
          validates_uniqueness_of key, :case_sensitive => false
        end

        def self.locate(key)
          where(auth_key => key).first
        end
      end
    end
  end
end
