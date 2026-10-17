require 'hashie/mash'

module OmniAuth
  # Generic helper hash that allows method access on deeply nested keys.
  class KeyStore < ::Hashie::Mash
    # Disables Hashie's warnings when a key overrides a Mash method
    def self.override_logging
      disable_warnings
    end

    # Disable on loading of the class
    override_logging
  end
end
