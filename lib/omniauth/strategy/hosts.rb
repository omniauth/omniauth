module OmniAuth
  module Strategy
    # Guards against forged hosts. Unless a full_host is set, callback URLs
    # use the request's host, which comes from the Host or X-Forwarded-Host
    # header, so a forged one would send the provider a redirect_uri on
    # another host.
    module Hosts
    protected

      # Whether callback URLs may use this request's host. They always may
      # when a full_host is set, since then the request's host isn't used.
      # Otherwise, if OmniAuth.config.allowed_hosts is set, the host must
      # match one of its entries: a string matches the whole host, ignoring
      # case, and a regexp must match the whole host.
      def allowed_host?
        return true if full_host_set?

        allowed_hosts = OmniAuth.config.allowed_hosts
        return true unless allowed_hosts

        host = request.host
        allowed_hosts.any? do |allowed|
          allowed.instance_of?(Regexp) ? /\A(?:#{allowed})\z/ === host : allowed.casecmp?(host)
        end
      end

      def full_host_set?
        !(options[:full_host] || OmniAuth.config.full_host).nil?
      end

      def warn_if_using_request_host
        return if full_host_set? || OmniAuth.config.allowed_hosts

        log :warn, <<-WARN
  OmniAuth is building callback URLs from the request's host, which comes
  from the Host or X-Forwarded-Host header and can be forged unless your
  app or a proxy in front of it checks it. To fix this, set either:
  OmniAuth.config.full_host = 'https://example.com'
  OmniAuth.config.allowed_hosts = ['example.com']
        WARN
      end

      def invalid_host!
        fail!(:invalid_host, Error.new('The request host is not in OmniAuth.config.allowed_hosts'))
      end
    end
  end
end
