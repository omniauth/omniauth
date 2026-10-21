module OmniAuth
  # A Hash with string keys that you can also read and write with methods,
  # and whose nested hashes are KeyStores too. Strategy options and auth
  # hashes are KeyStores:
  #
  #   auth = OmniAuth::AuthHash.new(:info => {:email => 'a@example.com'})
  #   auth.info.email   # => "a@example.com"
  #   auth[:info][:email] == auth['info']['email'] # => true
  #   auth.info.email?  # => true
  #   auth.uid          # => nil
  #   auth.uid = '123'
  class KeyStore < Hash
    # The class that nested hashes are converted to.
    def self.subkey_class
      self
    end

    # Unlike Hash.new, takes no default value or block.
    def initialize(source = nil)
      update(source) if source
    end

    def [](key)
      super(convert_key(key))
    end

    def []=(key, value)
      string_key = convert_key(key)
      super(string_key, convert_value(string_key, value))
    end
    alias store []=

    # Steep can't match this pass-through call to Hash#fetch's overloads.
    def fetch(key, *args)
      super(convert_key(key), *args) # steep:ignore
    end

    def delete(key)
      super(convert_key(key))
    end

    def key?(key)
      super(convert_key(key))
    end
    alias has_key? key?
    alias include? key?
    alias member? key?

    def dig(key, *keys)
      super(convert_key(key), *keys)
    end

    def values_at(*keys)
      super(*keys.collect { |key| convert_key(key) })
    end

    def update(other)
      other.each_pair { |key, value| self[key] = value }
      self
    end
    alias merge! update

    def merge(other)
      dup.update(other)
    end

    # Merges other into this KeyStore, merging nested hashes key by key
    # instead of replacing them.
    def deep_merge!(other)
      other.each_pair do |key, value|
        current = self[key]
        if current.is_a?(KeyStore) && value.is_a?(Hash)
          current.deep_merge!(value)
        else
          self[key] = value
        end
      end
      self
    end
    alias deep_update deep_merge!

    def deep_merge(other)
      dup.deep_merge!(other)
    end

    # Copies nested KeyStores too, so changing the copy never changes the
    # original.
    def initialize_copy(other)
      super
      each_pair { |key, value| self[key] = value.dup if value.is_a?(KeyStore) }
    end

    def select
      selected = super #: Hash[untyped, untyped]
      self.class.new(selected)
    end

    # Built on select, since Hash#reject on a subclass warns on Ruby 2.x.
    def reject
      select { |key, value| !yield(key, value) }
    end

    def slice(*keys)
      self.class.new(super(*keys.collect { |key| convert_key(key) }))
    end

    def except(*keys)
      string_keys = keys.collect { |key| convert_key(key) }
      reject { |key, _| string_keys.include?(key) }
    end

    # Converts this KeyStore, and every KeyStore nested in it, to a plain
    # Hash, with string keys or, given symbolize_keys: true, symbol keys.
    def to_hash(symbolize_keys: false)
      hash = {} #: Hash[String | Symbol, untyped]
      each_pair do |key, value|
        hash[symbolize_keys ? key.to_sym : key] = plain_value(value, symbolize_keys)
      end
      hash
    end

    # Reads a key with `store.key`, writes one with `store.key = value`,
    # and checks one with `store.key?`, which is true unless the value is
    # nil or false.
    def method_missing(method_name, value = nil)
      name = method_name.to_s
      case name[-1]
      when '='
        self[name.chop] = value
      when '?'
        !!self[name.chop]
      else
        self[name]
      end
    end

    def respond_to_missing?(method_name, _include_private)
      key?(method_name) || method_name.match?(/[=?]\z/)
    end

  protected

    def convert_key(key)
      key.instance_of?(Symbol) ? key.to_s : key
    end

    # Keeps a KeyStore as it is and converts any other Hash, including
    # those in arrays.
    def convert_value(_key, value)
      return value if value.is_a?(KeyStore)

      case value
      when Hash then self.class.subkey_class.new(value)
      when Array then value.collect { |item| convert_value(nil, item) }
      else value
      end
    end

    def plain_value(value, symbolize_keys)
      case value
      when KeyStore then value.to_hash(:symbolize_keys => symbolize_keys)
      when Array then value.collect { |item| plain_value(item, symbolize_keys) }
      else value
      end
    end
  end
end
