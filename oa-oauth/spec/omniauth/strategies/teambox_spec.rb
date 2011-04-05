require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OmniAuth::Strategies::Teambox do
  it_should_behave_like "an oauth2 strategy"
end
