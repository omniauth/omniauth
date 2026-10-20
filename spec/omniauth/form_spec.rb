require 'helper'

describe OmniAuth::Form do
  around do |example|
    original_css = OmniAuth.config.form_css
    OmniAuth.config.form_css = 'body { color: red; }'
    example.run
    OmniAuth.config.form_css = original_css
  end

  def head(form_tag, title: 'Authentication Info Required', header_info: '')
    [
      '      <!DOCTYPE html>',
      '      <html>',
      '      <head>',
      '        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
      "        <title>#{title}</title>",
      '        ',
      "<style type='text/css'>body { color: red; }</style>",
      "        #{header_info}",
      '      </head>',
      '      <body>',
      "      <h1>#{title}</h1>",
      "      #{form_tag}",
      ''
    ].join("\n")
  end

  def foot
    "      </form>\n      </body>\n      </html>\n"
  end

  def page(form_tag, fields, **options)
    head(form_tag, **options) + fields + foot
  end

  describe '.build' do
    it 'yields the instance when called with a block and argument' do
      yielded = nil
      context = nil
      form = OmniAuth::Form.build(:title => 'Built') do |f|
        yielded = f
        context = self
        f.text_field('Name', 'name')
      end

      expect(form).to be_instance_of(OmniAuth::Form)
      expect(yielded).to equal(form)
      expect(context).to equal(self)
      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<label for='name'>Name:</label>\n<input type='text' id='name' name='name'/>\n<button type='submit'>Connect</button>",
             :title => 'Built')
      )
    end

    it 'evaluates in the instance when called with a block and no argument' do
      context = nil
      form = OmniAuth::Form.build do
        context = self
        text_field('Name', 'name')
      end

      expect(context).to equal(form)
      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<label for='name'>Name:</label>\n<input type='text' id='name' name='name'/>\n<button type='submit'>Connect</button>")
      )
    end

    it 'builds an OmniAuth::Form even when called on a subclass' do
      expect(Class.new(OmniAuth::Form).build {}).to be_instance_of(OmniAuth::Form)
    end
  end

  describe '#initialize' do
    # Avoids "instance variable not initialized" warnings on Ruby < 3.0.
    it 'initializes the button and footer state' do
      form = described_class.new
      expect(form.instance_variable_defined?(:@with_custom_button)).to be true
      expect(form.instance_variable_get(:@with_custom_button)).to be false
      expect(form.instance_variable_defined?(:@footer)).to be true
      expect(form.instance_variable_get(:@footer)).to be_nil
    end

    it 'renders the default page' do
      expect(OmniAuth::Form.new.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Connect</button>")
      )
    end

    it 'renders the title, header info, method and url options' do
      form = OmniAuth::Form.new(:title => 'Sign In', :header_info => '<script></script>', :method => 'get', :url => '/awesome')

      expect(form.to_html).to eq(
        page("<form method='get' action='/awesome' noValidate='noValidate'>",
             "\n<button type='submit'>Connect</button>",
             :title => 'Sign In', :header_info => '<script></script>')
      )
    end

    it 'falls back to the defaults for nil options' do
      form = OmniAuth::Form.new(:title => nil, :header_info => nil, :method => nil)

      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Connect</button>")
      )
    end

    it 'fills in the default options' do
      options = {:url => '/awesome'}

      expect(OmniAuth::Form.new(options).options).to equal(options)
      expect(options).to eq(
        :url => '/awesome', :title => 'Authentication Info Required', :header_info => '', :method => 'post'
      )
    end
  end

  describe '#label_field' do
    it 'adds a label and returns the form' do
      form = OmniAuth::Form.new

      expect(form.label_field('Name', 'name')).to equal(form)
      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<label for='name'>Name:</label>\n<button type='submit'>Connect</button>")
      )
    end
  end

  describe '#input_field' do
    it 'adds an input and returns the form' do
      form = OmniAuth::Form.new

      expect(form.input_field('email', 'mail')).to equal(form)
      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<input type='email' id='mail' name='mail'/>\n<button type='submit'>Connect</button>")
      )
    end
  end

  describe '#text_field' do
    it 'adds a labeled text input and returns the form' do
      form = OmniAuth::Form.new

      expect(form.text_field('Name', 'name')).to equal(form)
      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<label for='name'>Name:</label>\n<input type='text' id='name' name='name'/>\n<button type='submit'>Connect</button>")
      )
    end
  end

  describe '#password_field' do
    it 'adds a labeled password input and returns the form' do
      form = OmniAuth::Form.new

      expect(form.password_field('pass', 'password')).to equal(form)
      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<label for='password'>pass:</label>\n<input type='password' id='password' name='password'/>\n<button type='submit'>Connect</button>")
      )
    end
  end

  describe '#button' do
    it 'replaces the default button' do
      form = OmniAuth::Form.new
      form.button('Sign In')

      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Sign In</button>")
      )
    end
  end

  describe '#html' do
    it 'appends to the html body' do
      form = OmniAuth::Form.build { @html = +'<p></p>' }
      form.html('<h1></h1>')

      expect(form.instance_variable_get(:@html)).to eq '<p></p><h1></h1>'
    end
  end

  describe '#fieldset' do
    it 'creates a fieldset with options' do
      form = OmniAuth::Form.new
      options = {:style => 'color: red', :id => 'fieldSetId'}

      expect(form.fieldset('legendary', options) { text_field('Name', 'name') }).to equal(form)
      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<fieldset style='color: red' id='fieldSetId'>\n  <legend>legendary</legend>\n" \
             "\n<label for='name'>Name:</label>\n<input type='text' id='name' name='name'/>" \
             "\n</fieldset>\n<button type='submit'>Connect</button>")
      )
    end

    it 'creates a fieldset without options' do
      form = OmniAuth::Form.new
      form.fieldset('legendary') {}

      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<fieldset>\n  <legend>legendary</legend>\n\n</fieldset>\n<button type='submit'>Connect</button>")
      )
    end

    it 'omits nil options' do
      form = OmniAuth::Form.new
      form.fieldset('legendary', :style => nil, :id => nil) {}

      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>",
             "\n<fieldset>\n  <legend>legendary</legend>\n\n</fieldset>\n<button type='submit'>Connect</button>")
      )
    end
  end

  describe '#header' do
    it 'appends a header and returns the form' do
      form = OmniAuth::Form.new

      expect(form.header('Again', 'info')).to equal(form)
      expect(form.to_html).to eq(
        head("<form method='post' noValidate='noValidate'>") +
        page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Connect</button>",
             :title => 'Again', :header_info => 'info')
      )
    end

    it 'includes the form action when a url is set' do
      form = OmniAuth::Form.new(:url => '/awesome', :method => 'get')
      form.header('Again', '')

      expect(form.to_html).to eq(
        head("<form method='get' action='/awesome' noValidate='noValidate'>") +
        page("<form method='get' action='/awesome' noValidate='noValidate'>", "\n<button type='submit'>Connect</button>",
             :title => 'Again')
      )
    end

    it 'omits the form action when the url is nil' do
      form = OmniAuth::Form.new(:url => nil)
      form.header('Again', '')

      expect(form.to_html).to eq(
        head("<form method='post' noValidate='noValidate'>") +
        page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Connect</button>",
             :title => 'Again')
      )
    end
  end

  describe '#footer' do
    it 'only adds the footer once and returns the form' do
      form = OmniAuth::Form.new

      expect(form.footer).to equal(form)
      expect(form.footer).to equal(form)
      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Connect</button>")
      )
    end

    it 'omits the default button when a custom button was added' do
      form = OmniAuth::Form.new
      form.button('Sign In')
      form.footer

      expect(form.instance_variable_get(:@html)).to eq(
        page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Sign In</button>")
      )
    end
  end

  describe '#to_html' do
    it 'closes the form and returns the html' do
      form = OmniAuth::Form.new

      expect(form.to_html).to eq(
        page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Connect</button>")
      )
      expect(form.to_html).to equal(form.to_html)
    end
  end

  describe '#to_response' do
    it 'returns a rack response containing the page' do
      html = page("<form method='post' noValidate='noValidate'>", "\n<button type='submit'>Connect</button>")
      status, headers, body = OmniAuth::Form.new.to_response

      expect(status).to eq(200)
      # Rack 3 also adds content-length; Rack 2 doesn't.
      expect(headers['content-type']).to eq('text/html')
      expect(body.to_enum(:each).to_a.join).to eq(html)
    end
  end
end
