module OmniAuth
  # The AuthHash is a normalized schema returned by all OmniAuth
  # strategies. It maps as much user information as the provider
  # is able to provide into the InfoHash (stored as the `'info'`
  # key).
  class AuthHash < OmniStruct

    # Tells you if this is considered to be a valid
    # OmniAuth AuthHash. The requirements for that
    # are that it has a provider name, a uid, and a
    # valid info hash. See InfoHash#valid? for
    # more details there.
    def valid?
      uid && provider && info && info.valid?
    end

    def on_write(key, value)
      if :info == key && !value.is_a?(InfoHash)
        return InfoHash.new(value) if value
      else
        super
      end
    end

    class InfoHash < OmniStruct
      def self.subkey_class
      end

      def [](key)
        if :name == key || 'name' == key
          name = super
          return name if name
          return "#{first_name} #{last_name}".strip if first_name || last_name
          return nickname if nickname
          return email if email
          nil
        else
          super
        end
      end

      def name
        self[:name]
      end

      def name?
        !!self.name # rubocop:disable DoubleNegation
      end
      alias_method :valid?, :name?

      def to_hash(options = {})
        hash = super
        hash["name"] ||= name if name
        hash
      end
    end
  end
end
