module OmniAuth
  module Utils
    module_function

    def form_css
      "<style type='text/css'>#{OmniAuth.config.form_css}</style>"
    end

    def deep_merge(hash, other_hash)
      target = hash.dup

      other_hash.keys.each do |key|
        if other_hash[key].is_a?(::Hash) && hash[key].is_a?(::Hash)
          target[key] = deep_merge(target[key], other_hash[key])
          next
        end

        target[key] = other_hash[key]
      end

      target
    end

    def camelize(word, first_letter_in_uppercase = true)
      return OmniAuth.config.camelizations[word.to_s] if OmniAuth.config.camelizations[word.to_s]

      if first_letter_in_uppercase
        word.to_s.gsub(%r{/(.?)}) { '::' + Regexp.last_match[1].upcase }.gsub(/(^|_)(.)/) { Regexp.last_match[2].upcase }
      else
        word.first + camelize(word)[1..-1]
      end
    end
  end
end
