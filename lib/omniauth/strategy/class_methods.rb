module OmniAuth
  module Strategy
    module ClassMethods
      DISPATCH_METHODS = %i[call! phase_call options_call? request_call? on_auth_path?].freeze
      private_constant :DISPATCH_METHODS

      # True when requests are dispatched by OmniAuth's own #call! and its
      # phase checks, so #call can tell which ones would go to the app.
      # They may live in Strategy or in a module it includes, like Paths.
      # Methods patched directly onto Strategy count as its own.
      #
      # @api private
      def default_dispatch?
        return @default_dispatch if instance_variable_defined?(:@default_dispatch)

        @default_dispatch = DISPATCH_METHODS.all? { |m| Strategy.ancestors.include?(instance_method(m).owner) }
      end

      # Returns an inherited set of default options set at the class-level
      # for each strategy.
      def default_options
        @default_options ||= begin
          parent = superclass
          Options.new((parent.default_options if parent.is_a?(ClassMethods)))
        end
      end

      # This allows for more declarative subclassing of strategies by allowing
      # default options to be set using a simple configure call.
      #
      # @param options [Hash] If supplied, these will be the default options (deep-merged into the superclass's default options).
      # @yield [Options] The options Mash that allows you to set your defaults as you'd like.
      #
      # @example Using a yield to configure the default options.
      #
      #   class MyStrategy
      #     include OmniAuth::Strategy
      #
      #     configure do |c|
      #       c.foo = 'bar'
      #     end
      #   end
      #
      # @example Using a hash to configure the default options.
      #
      #   class MyStrategy
      #     include OmniAuth::Strategy
      #     configure foo: 'bar'
      #   end
      def configure(options = nil)
        if block_given?
          yield default_options
        else
          default_options.deep_merge!(options || {})
        end
      end

      # Directly declare a default option for your class. This is a useful from
      # a documentation perspective as it provides a simple line-by-line analysis
      # of the kinds of options your strategy provides by default.
      #
      # @param name [Symbol] The key of the default option in your configuration hash.
      # @param value [Object] The value your object defaults to. Nil if not provided.
      #
      # @example
      #
      #   class MyStrategy
      #     include OmniAuth::Strategy
      #
      #     option :foo, 'bar'
      #     option
      #   end
      def option(name, value = nil)
        default_options[name] = value
      end

      # Sets (and retrieves) option key names for initializer arguments to be
      # recorded as. This takes care of 90% of the use cases for overriding
      # the initializer in OmniAuth Strategies.
      def args(args = nil)
        if args
          @args = args.is_a?(Array) ? args : [args]
          return
        end
        return @args if instance_variable_defined?(:@args)

        parent = superclass
        parent.is_a?(ClassMethods) ? parent.args : []
      end

      %w[uid info extra credentials].each do |fetcher|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          attr_reader :#{fetcher}_proc                                 # attr_reader :uid_proc
          private :#{fetcher}_proc                                     # private :uid_proc

          def #{fetcher}(&block)                                       # def uid(&block)
            return #{fetcher}_proc unless block_given?                 #   return uid_proc unless block_given?
            @#{fetcher}_proc = block                                   #   @uid_proc = block
          end                                                          # end

          def #{fetcher}_stack(context)                                # def uid_stack(context)
            compile_stack(self.ancestors, :#{fetcher}, context)        #   compile_stack(self.ancestors, :uid, context)
          end                                                          # end
        RUBY
      end

      def compile_stack(ancestors, method, context)
        stack = ancestors.inject([]) do |a, ancestor|
          # Only strategy classes define these blocks. Other ancestors may
          # respond to the same names (e.g. a monkeypatched Object#info).
          a << context.instance_eval(&ancestor.public_send(method)) if ancestor.is_a?(ClassMethods) && ancestor.public_send(method)
          a
        end
        stack.reverse
      end
    end
  end
end
