module OmniAuth
  module Strategy
    # Builds the auth hash from the uid, info, credentials, and extra
    # blocks a strategy declares with the class-level fetcher DSL.
    module Fetchers
      def uid
        self.class.uid_stack(self).last
      end

      def info
        merge_stack(self.class.info_stack(self))
      end

      def credentials
        merge_stack(self.class.credentials_stack(self))
      end

      def extra
        merge_stack(self.class.extra_stack(self))
      end

      def auth_hash
        credentials_data = credentials
        extra_data = extra
        AuthHash.new(:provider => name, :uid => uid).tap do |auth|
          auth.info = info unless skip_info?
          auth.credentials = credentials_data if credentials_data
          auth.extra = extra_data if extra_data
        end
      end

      # Determines whether or not user info should be retrieved. This
      # allows some strategies to save a call to an external API service
      # for existing users. You can use it either by setting the `:skip_info`
      # to true or by setting `:skip_info` to a Proc that takes a uid and
      # evaluates to true when you would like to skip info.
      #
      # @example
      #
      #   use MyStrategy, :skip_info => lambda{|uid| User.find_by_uid(uid)}
      def skip_info?
        return false unless options.skip_info?
        return true unless options.skip_info.respond_to?(:call)

        options.skip_info.call(uid)
      end

    protected

      def merge_stack(stack)
        merged = {} #: Hash[untyped, untyped]
        stack.each { |hash| merged.merge!(hash) }
        merged
      end
    end
  end
end
