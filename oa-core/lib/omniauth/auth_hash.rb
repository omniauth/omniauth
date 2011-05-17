require 'hashie/mash'

module OmniAuth
  class AuthHash < Hashie::Mash
    
    # Tells you if this is considered to be a valid
    # OmniAuth AuthHash. The requirements for that
    # are that it has a provider name, a uid, and a
    # valid user_info hash. See UserInfo#valid? for
    # more details there.
    def valid?
      uid? && provider? && (!user_info? || user_info.valid?)
    end

    def regular_writer(key, value)
      if key.to_s == 'user_info' && !value.is_a?(UserInfo)
        value = UserInfo.new(value)
      end
      super
    end

    class UserInfo < Hashie::Mash
      def valid?
        name?
      end
      
      def name
        return self[:name] if name?
        return "#{first_name} #{last_name}".strip if first_name? || last_name?
        return nickname if nickname?
        return email if email?
        nil
      end
    end
  end
end
