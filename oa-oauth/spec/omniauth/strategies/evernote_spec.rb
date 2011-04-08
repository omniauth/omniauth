unless defined?(JRUBY_VERSION)
  require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

  describe OmniAuth::Strategies::Evernote do
    it_should_behave_like "an oauth strategy"
  end
end
