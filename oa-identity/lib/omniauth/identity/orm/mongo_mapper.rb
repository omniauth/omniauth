require 'omniauth/identity'

module OmniAuth
  module Identity
    class Model
      include OmniAuth::Identity::Interface
      include MongoMapper::Document

      key :uid, String
      key :crypted_password, String
      key :crypted_password_salt, 

      before_validation(:on => :create) do
        self.uid ||= UUID.generate(:compact)
      end

      def auth_hash
        {
          'uid' => self.uid,
          'user_info' => {
            
          }
        }
      end
    end
  end
end
