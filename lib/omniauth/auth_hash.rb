require 'hashie/mash'

module OmniAuth
  # The AuthHash is a normalized schema returned by all OmniAuth
  # strategies. It maps as much user information as the provider
  # is able to provide into the InfoHash (stored as the `'info'`
  # key).
  class AuthHash < Hashie::Mash
    # Tells you if this is considered to be a valid
    # OmniAuth AuthHash. The requirements for that
    # are that it has a provider name, a uid, and a
    # valid info hash. See InfoHash#valid? for
    # more details there.
    def valid?
      uid? && provider? && name?
    end

    def name
      return self[:name] if self[:name]
      return nil unless info?
      return "#{info.first_name} #{info.last_name}".strip if info.first_name? || info.last_name?
      return info.nickname if info.nickname?
      return info.email if info.email?
      nil
    end

    def name?; !!name end

    def regular_writer(key, value)
      if key.to_s == 'info' && !value.is_a?(InfoHash)
        value = InfoHash.new(value)
      end
      super
    end

    def to_hash
      hash = super
      hash['name'] ||= name
      hash
    end

    class InfoHash < Hashie::Mash
      def valid?
        name?
      end
    end
  end
end
