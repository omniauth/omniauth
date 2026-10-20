require 'omniauth/key_store'

module OmniAuth
  # The AuthHash is a normalized schema returned by all OmniAuth
  # strategies. It maps as much user information as the provider
  # is able to provide into the InfoHash (stored as the `'info'`
  # key).
  class AuthHash < OmniAuth::KeyStore
    def self.subkey_class
      Hashie::Mash
    end

    # Tells you if this is considered to be a valid
    # OmniAuth AuthHash. The requirements for that
    # are that it has a provider name, a uid, and a
    # valid info hash. See InfoHash#valid? for
    # more details there.
    def valid?
      info = info()
      uid? && provider? && !info.nil? && info.valid?
    end

    def regular_writer(key, value)
      value = InfoHash.new(value) if key.eql?('info') && value.is_a?(Hash) && !value.is_a?(InfoHash)
      super
    end

    class InfoHash < OmniAuth::KeyStore
      def self.subkey_class
        Hashie::Mash
      end

      def name
        return fetch(:name) if self[:name]
        return "#{first_name} #{last_name}".strip if first_name? || last_name?
        return nickname if nickname?

        email if email?
      end

      def name?
        !!name
      end
      alias valid? name?

      # slice, except, select, and reject return a subset of the info,
      # which shouldn't gain a calculated name when converted with #to_hash.
      def slice(*keys)
        subset(super)
      end

      def except(*keys)
        subset(super)
      end

      def select
        subset(super)
      end

      def reject
        subset(super)
      end

      def to_hash
        hash = super
        hash['name'] ||= name unless instance_variable_defined?(:@subset)
        hash
      end

    private

      # Only whether @subset is defined matters, not its value.
      def subset(info)
        info.instance_variable_set(:@subset, nil)
        info
      end
    end
  end
end
