module OmniAuth
  module Strategy
    # Works out the request, callback, and setup paths for a strategy and
    # whether the current request is on one of them, plus the full URLs
    # built from them.
    module Paths
      # Returns true if the environment recognizes either the
      # request or callback path.
      def on_auth_path?
        on_request_path? || on_callback_path?
      end

      def on_request_path?
        if options[:request_path].respond_to?(:call)
          options[:request_path].call(env)
        else
          on_path?(request_path)
        end
      end

      def on_callback_path?
        on_path?(callback_path) || current_path.sub(FORMAT_EXTENSION_REGEX, EMPTY_STRING).casecmp(callback_path).zero?
      end

      def on_path?(path)
        current_path.casecmp(path).zero?
      end

      def path_prefix
        options[:path_prefix] || OmniAuth.config.path_prefix
      end

      def custom_path(kind)
        if options[kind].respond_to?(:call)
          result = options[kind].call(env)
          return nil unless result.is_a?(String)

          result
        else
          options[kind]
        end
      end

      def request_path
        @request_path ||=
          if options[:request_path].is_a?(String)
            options[:request_path]
          else
            "#{script_name}#{path_prefix}/#{name}"
          end
      end

      def callback_path
        @callback_path ||= callback_path_option || custom_path(:request_path) || "#{script_name}#{path_prefix}/#{name}/callback"
      end

      def setup_path
        options[:setup_path] || "#{path_prefix}/#{name}/setup"
      end

      CURRENT_PATH_REGEX = %r{/$}.freeze
      FORMAT_EXTENSION_REGEX = /\.\w+\z/.freeze
      EMPTY_STRING = ''.freeze
      def current_path
        @current_path ||= request.path.downcase.sub(CURRENT_PATH_REGEX, EMPTY_STRING)
      end

      def query_string
        request.query_string.empty? ? '' : "?#{request.query_string}"
      end

      def full_host
        host = OmniAuth.config.full_host
        case host
        when String then host
        when Proc then host.call(env)
        else full_host_from_request
        end
      end

      def callback_url
        full_host + callback_path + query_string
      end

      def script_name
        current_env = @env
        return '' if current_env.nil?

        current_env['SCRIPT_NAME'] || ''
      end

    protected

      # The :callback_path option: a string, or a lambda that returns true
      # when the current path is the callback path.
      def callback_path_option
        option = options[:callback_path]
        return option if option.is_a?(String)

        current_path if option.respond_to?(:call) && option.call(env)
      end

      # The scheme, host, and port of the current request, or an empty
      # string if the request URL isn't absolute.
      def full_host_from_request
        # in Rack 1.3.x, request.url explodes if scheme is nil
        return '' unless request.scheme && URI.parse(request.url).absolute?

        uri = URI.parse(request.url.gsub(/\?.*$/, ''))
        uri.path = ''
        # sometimes the url is actually showing http inside rails because the
        # other layers (like nginx) have handled the ssl termination.
        uri.scheme = 'https' if ssl?
        uri.to_s
      end

      # Rack env values that mean the request came in over HTTPS.
      SSL_ENV_VALUES = {
        'HTTPS' => 'on',
        'HTTP_X_FORWARDED_SSL' => 'on',
        'HTTP_X_FORWARDED_SCHEME' => 'https',
        'rack.url_scheme' => 'https'
      }.freeze

      def ssl?
        # A proxy chain can list several protocols; the first is the client's.
        forwarded_proto = request.env['HTTP_X_FORWARDED_PROTO'].to_s.split(',').first
        forwarded_proto == 'https' || SSL_ENV_VALUES.any? { |key, value| request.env[key] == value }
      end
    end
  end
end
