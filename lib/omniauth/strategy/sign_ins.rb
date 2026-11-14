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
    # callback_sign_in_key to return the value from the callback. It can
    # store its own values for the callback in the same sign-in, such as
    # OAuth 2.0's PKCE verifier, and read them back with
    # remembered_sign_in.
    #
    # The sign-ins live in the session, which is often a 4 KB cookie, so
    # each one stores only what isn't empty.
    module SignIns
      # How many sign-ins are remembered. Remembering another forgets the
      # oldest.
      MAX_REMEMBERED_SIGN_INS = 3

      # The largest params, counting the bytes of their keys and values, that
      # a sign-in remembers. The params come from the request, so they can be any
      # size, and a few large ones would overflow a cookie session.
      MAX_REMEMBERED_PARAMS_BYTESIZE = 512

      # The session key of the request phase's origin, frozen so moving it
      # doesn't make a new string in every request phase: unlike
      # session[...], delete has no fast path for a string literal.
      ORIGIN_KEY = 'omniauth.origin'.freeze

      # Remembers the current request phase's sign-in under key, which the
      # provider sends back to the callback: the strategy's own data, plus
      # the origin and params OmniAuth stored, under "origin" and "params",
      # so data shouldn't use those keys.
      def remember_sign_in(key, data = nil)
        return if key.empty?

        sign_in = data ? data.dup : {} #: Hash[String, untyped]
        add_origin_and_params(sign_in)
        sign_ins = remembered_sign_ins
        sign_ins.delete(key)
        sign_ins[key] = sign_in
        session['omniauth.sign_ins'] = sign_ins.to_a.last(MAX_REMEMBERED_SIGN_INS).to_h
      end

      # The key the callback sends back, which a strategy that calls
      # remember_sign_in returns. Nil for a strategy that doesn't.
      def callback_sign_in_key; end

    protected

      # The sign-in remembered under the callback's key, removed from the
      # session, or nil if none is. It's the same for the whole callback,
      # so the strategy can read its own data after OmniAuth takes the
      # origin and params.
      def remembered_sign_in
        return @remembered_sign_in if instance_variable_defined?(:@remembered_sign_in)

        key = callback_sign_in_key
        sign_ins = remembered_sign_ins
        remembered = sign_ins.keys.detect { |stored| Rack::Utils.secure_compare(stored, key) } if key.instance_of?(String)
        sign_in = sign_ins.delete(remembered)
        session['omniauth.sign_ins'] = sign_ins if sign_in
        @remembered_sign_in = sign_in
      end

      # The origin and params for this callback, removed from the session:
      # the ones remembered under its key, or else omniauth.origin and
      # omniauth.params, which hold the latest sign-in's. Either may be
      # missing.
      def recall_sign_in
        fallback = {'origin' => session.delete('omniauth.origin'), 'params' => session.delete('omniauth.params')}
        remembered_sign_in || fallback
      end

      # A copy of the remembered sign-ins, which are changed by assigning the
      # session key, not in place.
      def remembered_sign_ins
        sign_ins = session['omniauth.sign_ins']
        sign_ins.is_a?(Hash) ? sign_ins.dup : {}
      end

    private

      # Adds the origin and params stored for the current request phase to
      # sign_in, leaving out an empty origin, empty params, and params too
      # large to keep.
      #
      # The origin moves out of omniauth.origin into the sign-in. Otherwise,
      # if this sign-in were abandoned, the next one would get its origin
      # whenever it has no origin param or referer of its own. So a second
      # sign-in remembered in the same request phase gets no origin.
      def add_origin_and_params(sign_in)
        origin = session.delete(ORIGIN_KEY)
        params = session['omniauth.params']
        sign_in['origin'] = origin unless origin.nil? || origin.empty?
        sign_in['params'] = params if params && !params.empty? && params_small_enough?(params)
      end

      def params_small_enough?(params)
        bytesize = params_bytesize(params)
        small_enough = bytesize <= MAX_REMEMBERED_PARAMS_BYTESIZE
        log :warn, "Not remembering #{bytesize} bytes of params for this sign-in, more than #{MAX_REMEMBERED_PARAMS_BYTESIZE}. The callback gets empty omniauth.params." unless small_enough
        small_enough
      end

      # The bytes in the keys and values of params, nested hashes and arrays
      # included. It's counted without building a string, since every
      # request phase with params counts them.
      def params_bytesize(value)
        case value
        when Hash
          total = 0
          value.each_pair { |key, nested| total += key.to_s.bytesize + params_bytesize(nested) }
          total
        when Array
          total = 0
          value.each { |nested| total += params_bytesize(nested) }
          total
        else
          value.to_s.bytesize
        end
      end
    end
  end
end
