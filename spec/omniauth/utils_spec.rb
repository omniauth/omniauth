require 'helper'

describe OmniAuth::Utils do
  describe '.form_css' do
    it 'returns a style tag with the configured form_css' do
      allow(OmniAuth).to receive(:config).and_return(double(:form_css => 'css.css'))
      expect(OmniAuth::Utils.form_css).to eq "<style type='text/css'>css.css</style>"
    end
  end

  describe '.deep_merge' do
    it 'combines hashes' do
      expect(OmniAuth::Utils.deep_merge({'abc' => {'def' => 123}}, 'abc' => {'foo' => 'bar'})).to eq('abc' => {'def' => 123, 'foo' => 'bar'})
    end
  end

  describe '.camelize' do
    it 'works on normal cases' do
      {
        'some_word' => 'SomeWord',
        'AnotherWord' => 'AnotherWord',
        'one' => 'One',
        'three_words_now' => 'ThreeWordsNow'
      }.each_pair { |k, v| expect(OmniAuth::Utils.camelize(k)).to eq(v) }
    end

    it 'works in special cases that have been added' do
      OmniAuth.config.add_camelization('oauth', 'OAuth')
      expect(OmniAuth::Utils.camelize(:oauth)).to eq('OAuth')
    end

    it 'doesn\'t uppercase the first letter when passed false' do
      expect(OmniAuth::Utils.camelize('apple_jack', false)).to eq('appleJack')
    end

    it 'replaces / with ::' do
      expect(OmniAuth::Utils.camelize('apple_jack/cereal')).to eq('AppleJack::Cereal')
      expect(OmniAuth::Utils.camelize('apple_jack/cereal', false)).to eq('appleJack::Cereal')
    end
  end
end
