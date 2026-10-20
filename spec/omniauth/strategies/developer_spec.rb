require 'helper'

describe OmniAuth::Strategies::Developer do
  let(:app) do
    Rack::Builder.new do |b|
      b.freeze_app
      b.use Rack::Session::Cookie, :secret => SecureRandom.hex(32)
      b.use OmniAuth::Strategies::Developer
      b.run lambda { |_env| [200, {}, ['Not Found']] }
    end.to_app
  end

  let(:form_head) do
    [
      '      <!DOCTYPE html>',
      '      <html>',
      '      <head>',
      '        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
      '        <title>User Info</title>',
      '        ',
      "<style type='text/css'>body { color: red; }</style>",
      '        ',
      '      </head>',
      '      <body>',
      '      <h1>User Info</h1>',
      "      <form method='get' action='/auth/developer/callback' noValidate='noValidate'>\n"
    ].join("\n")
  end

  def form_page(fields)
    inputs = fields.collect do |label, name|
      "\n<label for='#{name}'>#{label}:</label>\n<input type='text' id='#{name}' name='#{name}'/>"
    end
    "#{form_head}#{inputs.join}\n<button type='submit'>Sign In</button>      </form>\n      </body>\n      </html>\n"
  end

  context 'request phase' do
    around do |example|
      original_css = OmniAuth.config.form_css
      OmniAuth.config.form_css = 'body { color: red; }'
      example.run
      OmniAuth.config.form_css = original_css
    end

    it 'displays a form with a text field for each of the fields' do
      post '/auth/developer'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('text/html')
      expect(last_response.body).to eq(form_page([%w[Name name], %w[Email email]]))
    end

    context 'with custom fields' do
      let(:app) do
        Rack::Builder.new do |b|
          b.use Rack::Session::Cookie, :secret => SecureRandom.hex(32)
          b.use OmniAuth::Strategies::Developer, :fields => %i[first_name last_name]
          b.run lambda { |_env| [200, {}, ['Not Found']] }
        end.to_app
      end

      it 'humanizes the labels' do
        post '/auth/developer'

        expect(last_response.body).to eq(form_page([['First name', 'first_name'], ['Last name', 'last_name']]))
      end
    end

    it 'uses OmniAuth::Form even if a strategy is named Form' do
      stub_const('OmniAuth::Strategies::Form', Class.new)
      post '/auth/developer'

      expect(last_response.body).to eq(form_page([%w[Name name], %w[Email email]]))
    end
  end

  context 'callback phase' do
    let(:auth_hash) { last_request.env['omniauth.auth'] }

    context 'with default options' do
      before do
        get '/auth/developer/callback', :name => 'Example User', :email => 'user@example.com'
      end

      it 'sets the name in the auth hash' do
        expect(auth_hash.info.name).to eq('Example User')
      end

      it 'sets the email in the auth hash' do
        expect(auth_hash.info.email).to eq('user@example.com')
      end

      it 'sets the uid to the email' do
        expect(auth_hash.uid).to eq('user@example.com')
      end
    end

    context 'with custom options' do
      let(:app) do
        Rack::Builder.new do |b|
          b.freeze_app
          b.use Rack::Session::Cookie, :secret => SecureRandom.hex(32)
          b.use OmniAuth::Strategies::Developer, :fields => %i[first_name last_name], :uid_field => :last_name
          b.run lambda { |_env| [200, {}, ['Not Found']] }
        end.to_app
      end

      before do
        @options = {:uid_field => :last_name, :fields => %i[first_name last_name]}
        get '/auth/developer/callback', :first_name => 'Example', :last_name => 'User'
      end

      it 'sets info fields properly' do
        expect(auth_hash.info.name).to eq('Example User')
      end

      it 'sets the uid properly' do
        expect(auth_hash.uid).to eq('User')
      end
    end
  end
end
