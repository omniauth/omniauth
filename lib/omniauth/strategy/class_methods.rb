module OmniAuth
  module Strategy
    module ClassMethods
      # Returns an inherited set of default options set at the class-level
      # for each strategy.
      def default_options
        # existing = superclass.default_options if superclass.respond_to?(:default_options)
        existing = superclass.respond_to?(:default_options) ? superclass.default_options : {}
        @default_options ||= OmniAuth::Strategy::Options.new(existing)
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
          default_options.deep_merge!(options)
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
          @args = Array(args)
          return
        end
        existing = superclass.respond_to?(:args) ? superclass.args : []
        (instance_variable_defined?(:@args) && @args) || existing
      end

      %w[uid info extra credentials].each do |fetcher|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          attr_reader :#{fetcher}_proc
          private :#{fetcher}_proc

          def #{fetcher}(&block)
            return #{fetcher}_proc unless block_given?
            @#{fetcher}_proc = block
          end

          def #{fetcher}_stack(context)
            compile_stack(self.ancestors, :#{fetcher}, context)
          end
        RUBY
      end

      def compile_stack(ancestors, method, context)
        stack = ancestors.inject([]) do |a, ancestor|
          # Only strategy classes define these blocks. Other ancestors may
          # respond to the same names (e.g. a monkeypatched Object#info).
          a << context.instance_eval(&ancestor.send(method)) if ancestor.is_a?(ClassMethods) && ancestor.send(method)
          a
        end
        stack.reverse!
      end
    end
  end
end
