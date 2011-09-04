module OmniAuth
  module Version
    unless defined?(::OmniAuth::Version::MAJOR)
      MAJOR = 1
    end
    unless defined?(::OmniAuth::Version::MINOR)
      MINOR = 0
    end
    unless defined?(::OmniAuth::Version::PATCH)
      PATCH = 0
    end
    unless defined?(::OmniAuth::Version::PRE)
      PRE   = "alpha"
    end
    unless defined?(::OmniAuth::Version::STRING)
      STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
    end
  end
end
