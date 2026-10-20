require 'omniauth/key_store'
require 'omniauth/strategy/class_methods'
require 'omniauth/strategy/fetchers'
require 'omniauth/strategy/paths'
require 'omniauth/strategy/test_mode'

module OmniAuth
  class NoSessionError < StandardError; end
  # The Strategy is the base unit of OmniAuth's ability to
  # wrangle multiple providers. Each strategy provided by
  # OmniAuth includes this mixin to gain the default functionality
  # necessary to be compatible with the OmniAuth library.
  module Strategy # rubocop:disable ModuleLength
    include Fetchers
    include Paths
    include TestMode

    def self.included(base)
      OmniAuth.strategies << base

      base.extend ClassMethods
      base.class_eval do
        option :setup, false
        option :skip_info, false
        option :origin_param, 'origin'
      end
    end

    attr_reader :app, :env, :options, :response

    # Initializes the strategy by passing in the Rack endpoint,
    # the unique URL segment name for this strategy, and any
    # additional arguments. An `options` hash is automatically
    # created from the last argument if it is a hash.
    #
    # @param app [Rack application] The application on which this middleware is applied.
    #
    # @overload new(app, options = {})
    #   If nothing but a hash is supplied, initialized with the supplied options
    #   overriding the strategy's default options via a deep merge.
    # @overload new(app, *args, options = {})
    #   If the strategy has supplied custom arguments that it accepts, they may
    #   will be passed through and set to the appropriate values.
    #
    # @yield [Options] Yields options to block for further configuration.
    def initialize(app, *args, &block) # rubocop:disable UnusedMethodArgument
      @app = app
      @env = nil
      @options = self.class.default_options.dup

      options.deep_merge!(args.pop) if args.last.is_a?(Hash)
      options[:name] ||= self.class.to_s.split('::').last.downcase

      self.class.args.each do |arg|
        break if args.empty?

        options[arg] = args.shift
      end

      # Make sure that all of the args have been dealt with, otherwise error out.
      raise(ArgumentError.new("Received wrong number of arguments. #{args.inspect}")) unless args.empty?

      yield options if block_given?
    end

    def inspect
      "#<#{self.class}>"
    end

    # Direct access to the OmniAuth logger, automatically prefixed
    # with this strategy's name.
    #
    # @example
    #   log :warn, "This is a warning."
    def log(level, message)
      OmniAuth.logger.send(level, "(#{name}) #{message}")
    end

    # Duplicates this instance and runs #call! on it.
    # @param [Hash] The Rack environment.
    def call(env)
      dup.call!(env)
    end

    # The logic for dispatching any additional actions that need
    # to be taken. For instance, calling the request phase if
    # the request path is recognized.
    #
    # @param env [Hash] The Rack environment.
    def call!(env)
      unless env['rack.session']
        error = OmniAuth::NoSessionError.new('You must provide a session to use OmniAuth.')
        raise(error)
      end

      @env = env

      warn_if_using_get_on_request_path

      @env['omniauth.strategy'] = self if on_auth_path?

      return mock_call!(env) if OmniAuth.config.test_mode

      phase_call || @app.call(env)
    end

    # Runs the phase that matches the current request, or returns nil
    # if the request isn't for this strategy.
    def phase_call
      if on_auth_path? && options_request?
        options_call
      elsif on_request_path? && OmniAuth.config.allowed_request_methods.include?(request.request_method.downcase.to_sym)
        request_call
      elsif on_callback_path?
        callback_call
      elsif respond_to?(:other_phase)
        other_phase
      end
    rescue StandardError => e
      raise e if env.delete('omniauth.error.app')

      fail!(e.message, e)
    end

    def warn_if_using_get_on_request_path
      return unless on_request_path?
      return unless OmniAuth.config.allowed_request_methods.include?(:get)
      return if OmniAuth.config.silence_get_warning

      log :warn, <<-WARN
  You are using GET as an allowed request method for OmniAuth. This may leave
  you open to CSRF attacks. As of v2.0.0, OmniAuth by default allows only POST
  to its own routes. You should review the following resources to guide your
  mitigation:
  https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
  https://github.com/omniauth/omniauth/issues/960
  https://nvd.nist.gov/vuln/detail/CVE-2015-9284
  https://github.com/omniauth/omniauth/pull/809

  You can ignore this warning by setting:
  OmniAuth.config.silence_get_warning = true
      WARN
    end

    # Responds to an OPTIONS request.
    def options_call
      OmniAuth.config.before_options_phase.call(env) if OmniAuth.config.before_options_phase
      verbs = OmniAuth.config.allowed_request_methods.collect(&:to_s).collect(&:upcase).join(', ')
      [200, {'Allow' => verbs}, []]
    end

    # Performs the steps necessary to run the request phase of a strategy.
    def request_call # rubocop:disable CyclomaticComplexity, MethodLength, PerceivedComplexity
      setup_phase
      log :debug, 'Request phase initiated.'

      OmniAuth.config.request_validation_phase.call(env) if OmniAuth.config.request_validation_phase

      # store query params from the request url, extracted in the callback_phase
      session['omniauth.params'] = request.GET

      OmniAuth.config.before_request_phase.call(env) if OmniAuth.config.before_request_phase

      result = if options.form.respond_to?(:call)
        log :debug, 'Rendering form from supplied Rack endpoint.'
        options.form.call(env)
      elsif options.form
        log :debug, 'Rendering form from underlying application.'
        call_app!
      else
        store_origin if options.origin_param
        request_phase
      end
      
      OmniAuth.config.after_request_phase.call(env) if OmniAuth.config.after_request_phase
      result
    rescue OmniAuth::AuthenticityError => e
      fail!(:authenticity_error, e)
    end

    # Remembers where the user came from (the origin param, or else the
    # referer) so the callback phase can send them back there.
    def store_origin
      if request.params[options.origin_param]
        session['omniauth.origin'] = request.params[options.origin_param]
      elsif env['HTTP_REFERER'] && !env['HTTP_REFERER'].match(/#{request_path}$/)
        session['omniauth.origin'] = env['HTTP_REFERER']
      end
    end

    # Performs the steps necessary to run the callback phase of a strategy.
    def callback_call
      setup_phase
      log :debug, 'Callback phase initiated.'
      @env['omniauth.origin'] = session.delete('omniauth.origin')
      @env['omniauth.origin'] = nil if env['omniauth.origin'] == ''
      @env['omniauth.params'] = session.delete('omniauth.params') || {}
      OmniAuth.config.before_callback_phase.call(@env) if OmniAuth.config.before_callback_phase
      callback_phase
    end

    def options_request?
      request.request_method == 'OPTIONS'
    end

    # The setup phase looks for the `:setup` option to exist and,
    # if it is, will call either the Rack endpoint supplied to the
    # `:setup` option or it will call out to the setup path of the
    # underlying application. This will default to `/auth/:provider/setup`.
    def setup_phase
      if options[:setup].respond_to?(:call)
        log :debug, 'Setup endpoint detected, running now.'
        options[:setup].call(env)
      elsif options[:setup]
        log :debug, 'Calling through to underlying application for setup.'
        setup_env = env.merge('PATH_INFO' => setup_path, 'REQUEST_METHOD' => 'GET')
        call_app!(setup_env)
      end
    end

    # @abstract This method is called when the user is on the request path. You should
    # perform any information gathering you need to be able to authenticate
    # the user in this phase.
    def request_phase
      raise(NotImplementedError)
    end

    def callback_phase
      env['omniauth.auth'] = auth_hash
      call_app!
    end

    def call_app!(env = @env)
      @app.call(env)
    rescue StandardError => e
      env['omniauth.error.app'] = true
      raise e
    end

    def session
      @env['rack.session']
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def name
      options[:name]
    end

    def redirect(uri)
      r = Rack::Response.new

      if options[:iframe]
        r.write("<script type='text/javascript' charset='utf-8'>top.location.href = '#{uri}';</script>")
      else
        r.write("Redirecting to #{uri}...")
        r.redirect(uri)
      end

      r.finish
    end

    def user_info
      {}
    end

    def fail!(message_key, exception = nil)
      env['omniauth.error'] = exception
      env['omniauth.error.type'] = message_key.to_sym
      env['omniauth.error.strategy'] = self

      if exception
        log :error, "Authentication failure! #{message_key}: #{exception.class}, #{exception.message}"
      else
        log :error, "Authentication failure! #{message_key} encountered."
      end

      OmniAuth.config.on_failure.call(env)
    end

    class Options < OmniAuth::KeyStore; end

  protected

    def initialize_copy(*args)
      super
      @options = @options.dup
    end
  end
end
