require 'active_record'

module OmniAuth
  module Identity
    module Models
      class ActiveRecord << ::ActiveRecord::Base
        include OmniAuth::Identity::Model
      end
    end
  end
end
