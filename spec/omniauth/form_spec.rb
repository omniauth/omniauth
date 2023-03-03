require 'helper'

describe OmniAuth::Form do
  describe '.build' do
    it 'yields the instance when called with a block and argument' do
      OmniAuth::Form.build { |f| expect(f).to be_kind_of(OmniAuth::Form) }
    end

    it 'evaluates in the instance when called with a block and no argument' do
      f = OmniAuth::Form.build { @html = '<h1>OmniAuth</h1>' }
      expect(f.instance_variable_get(:@html)).to eq('<h1>OmniAuth</h1>')
    end
  end

  describe '#initialize' do
    it 'sets the form action to the passed :url option' do
      expect(OmniAuth::Form.new(:url => '/awesome').to_html).to be_include("action='/awesome'")
    end

    it 'sets an H1 tag from the passed :title option' do
      expect(OmniAuth::Form.new(:title => 'Something Cool').to_html).to be_include('<h1>Something Cool</h1>')
    end

    it 'sets the default form method to post' do
      expect(OmniAuth::Form.new.to_html).to be_include("method='post'")
    end

    it 'sets the form method to the passed :method option' do
      expect(OmniAuth::Form.new(:method => 'get').to_html).to be_include("method='get'")
    end
  end

  describe '#password_field' do
    it 'adds a labeled input field' do
      form = OmniAuth::Form.new.password_field('pass', 'password')
      form_html = form.to_html
      expect(form_html).to include('<label for=\'password\'>pass:</label>')
      expect(form_html).to include('<input type=\'password\' id=\'password\' name=\'password\'/>')
    end
  end

  describe '#html' do
    it 'appends to the html body' do
      form = OmniAuth::Form.build { @html = +'<p></p>' }
      form.html('<h1></h1>')

      expect(form.instance_variable_get(:@html)).to eq '<p></p><h1></h1>'
    end
  end

  describe 'fieldset' do
    it 'creates a fieldset with options' do
      form = OmniAuth::Form.new
      options = {:style => 'color: red', :id => 'fieldSetId'}
      expected = "<fieldset style='color: red' id='fieldSetId'>\n  <legend>legendary</legend>\n\n</fieldset>"

      form.fieldset('legendary', options) {}

      expect(form.to_html).to include expected
    end
  end
end
