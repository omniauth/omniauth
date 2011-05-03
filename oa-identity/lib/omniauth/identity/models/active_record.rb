require 'active_record'

module OmniAuth
  module Identity
    module Models
      class ActiveRecord < ::ActiveRecord::Base
        include OmniAuth::Identity::Model
        has_secure_password

        def self.locate(key)
          where(auth_key => key).first
        end
      end
    end
  end
end
