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
        @callback_path ||= begin
          path = options[:callback_path] if options[:callback_path].is_a?(String)
          path ||= current_path if options[:callback_path].respond_to?(:call) && options[:callback_path].call(env)
          path ||= custom_path(:request_path)
          path ||= "#{script_name}#{path_prefix}/#{name}/callback"
          path
        end
      end

      def setup_path
        options[:setup_path] || "#{path_prefix}/#{name}/setup"
      end

      CURRENT_PATH_REGEX = %r{/$}.freeze
      FORMAT_EXTENSION_REGEX = /\.\w+\z/.freeze
      EMPTY_STRING       = ''.freeze
      def current_path
        @current_path ||= request.path.downcase.sub(CURRENT_PATH_REGEX, EMPTY_STRING)
      end

      def query_string
        request.query_string.empty? ? '' : "?#{request.query_string}"
      end

      def full_host
        case OmniAuth.config.full_host
        when String
          OmniAuth.config.full_host
        when Proc
          OmniAuth.config.full_host.call(env)
        else
          # in Rack 1.3.x, request.url explodes if scheme is nil
          if request.scheme && URI.parse(request.url).absolute?
            uri = URI.parse(request.url.gsub(/\?.*$/, ''))
            uri.path = ''
            # sometimes the url is actually showing http inside rails because the
            # other layers (like nginx) have handled the ssl termination.
            uri.scheme = 'https' if ssl? # rubocop:disable BlockNesting
            uri.to_s
          else ''
          end
        end
      end

      def callback_url
        full_host + callback_path + query_string
      end

      def script_name
        return '' if @env.nil?
        @env['SCRIPT_NAME'] || ''
      end

    protected

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
