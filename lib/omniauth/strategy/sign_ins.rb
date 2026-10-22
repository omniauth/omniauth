module OmniAuth
  module Strategy
    # Keeps the origin and params of several sign-ins in progress at once,
    # for example in several tabs, so each callback gets its own. Without
    # this, the session holds a single omniauth.origin and omniauth.params,
    # and starting a sign-in replaces the last one's.
    #
    # A strategy opts in when its provider sends a value from the request
    # phase back to the callback, such as OAuth 2.0's state. Its request
    # phase calls remember_sign_in with that value, and it overrides
    # callback_sign_in_key to return the value from the callback.
    module SignIns
      # How many sign-ins are remembered. Remembering another forgets the
      # oldest.
      MAX_REMEMBERED_SIGN_INS = 5

      # Remembers the origin and params stored for the current request phase
      # under key, which the provider sends back to the callback.
      def remember_sign_in(key)
        return if key.empty?

        sign_ins = remembered_sign_ins
        sign_ins.delete(key)
        sign_ins[key] = {'origin' => session['omniauth.origin'], 'params' => session.fetch('omniauth.params')}
        session['omniauth.sign_ins'] = sign_ins.to_a.last(MAX_REMEMBERED_SIGN_INS).to_h
      end

      # The key the callback sends back, which a strategy that calls
      # remember_sign_in returns. Nil for a strategy that doesn't.
      def callback_sign_in_key; end

    protected

      # The origin and params for this callback, removed from the session:
      # the ones remembered under its key, or else omniauth.origin and
      # omniauth.params, which hold the latest sign-in's.
      def recall_sign_in
        fallback = {'origin' => session.delete('omniauth.origin'), 'params' => session.delete('omniauth.params')}
        key = callback_sign_in_key
        sign_ins = remembered_sign_ins
        remembered = sign_ins.keys.detect { |stored| Rack::Utils.secure_compare(stored, key) } if key.instance_of?(String)
        sign_in = sign_ins.delete(remembered)
        return fallback unless sign_in

        session['omniauth.sign_ins'] = sign_ins
        sign_in
      end

      # A copy of the remembered sign-ins, which are changed by assigning the
      # session key, not in place.
      def remembered_sign_ins
        sign_ins = session['omniauth.sign_ins']
        sign_ins.is_a?(Hash) ? sign_ins.dup : {}
      end
    end
  end
end
