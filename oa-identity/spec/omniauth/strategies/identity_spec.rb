require 'spec_helper'

describe OmniAuth::Strategies::Identity do
  def app
    Rack::Builder.new do
      use Rack::Session::Cookie
      use OmniAuth::Strategies::Identity, @options
      run @app || lambda{|env| [200, {}, env.inspect]}
    end.to_app
  end

  it 'should display a form' do
    get '/auth/identity'
    last_response.body.should be_include("<form")
  end
end
