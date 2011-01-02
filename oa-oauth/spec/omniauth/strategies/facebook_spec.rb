require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OmniAuth::Strategies::Facebook do
  it_should_behave_like "an oauth2 strategy"

  context "filter_params" do
    let(:app){ lambda{|env| [200, {}, ['Awesome']]}}
    let(:strategy) { OmniAuth::Strategies::Facebook.new(app) }
    subject { strategy.filter_callback_params(query_params) }

    context "no query parameters" do
      let(:query_params) { "" }
      it { should == "" }
    end

    context "query params other than 'code'" do
      let(:query_params) { "id=123&foo=bar" }
      it { should == "id=123&foo=bar" }
    end

    context "only param is 'code'" do
      let(:query_params) { "code=123abc" }
      it { should == "" }
    end

    context "multiple params including 'code'" do
      let(:query_params) { "id=1&code=123abc&foo=bar" }
      it { should == "id=1&foo=bar" }
    end

  end
end
