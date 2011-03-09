module OmniAuth
  module Identity
    module Interface
      extend ActiveSupport::Concern

      module ClassMethods
        # Taking a hash of identifying attribute data, this should
        # return an OmniAuth-compatible hash with the `uid` and
        # appropriate `user_info` set.
        def create(hash = {})
          raise NotImplementedError, "Your identity provider must implement a .create method."
        end

        # Taking an attribute name (usually "email" or "screen_name"),
        # this method should return an OmniAuth-compatible authentication
        # hash.
        def identify(key, value, password)
          raise NotImplementedError, "Your identity provider must implement a .identify method."
        end
      end
    end
  end
end
