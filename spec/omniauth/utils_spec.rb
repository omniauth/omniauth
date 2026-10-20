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

    it 'merges nested hashes recursively and adds new keys' do
      hash = {'a' => {'b' => {'c' => 1, 'd' => 2}}, 'e' => 3}
      other_hash = {'a' => {'b' => {'c' => 4}}, 'f' => 5}
      expect(OmniAuth::Utils.deep_merge(hash, other_hash)).to eq('a' => {'b' => {'c' => 4, 'd' => 2}}, 'e' => 3, 'f' => 5)
    end

    it 'replaces values unless both sides are hashes' do
      expect(OmniAuth::Utils.deep_merge({'a' => 1, 'b' => {'c' => 2}}, 'a' => {'d' => 3}, 'b' => 4)).to eq('a' => {'d' => 3}, 'b' => 4)
    end

    it 'merges hash subclasses' do
      hash = {'a' => OmniAuth::KeyStore.new('b' => 1)}
      other_hash = {'a' => OmniAuth::KeyStore.new('c' => 2)}
      expect(OmniAuth::Utils.deep_merge(hash, other_hash)).to eq('a' => {'b' => 1, 'c' => 2})
    end

    it 'does not modify its arguments' do
      hash = {'a' => {'b' => 1}}
      other_hash = {'a' => {'c' => 2}, 'd' => 3}
      OmniAuth::Utils.deep_merge(hash, other_hash)
      expect(hash).to eq('a' => {'b' => 1})
      expect(other_hash).to eq('a' => {'c' => 2}, 'd' => 3)
    end
  end

  describe '.camelize' do
    before do
      @old_camelizations = OmniAuth.config.camelizations
      OmniAuth.config.camelizations = @old_camelizations.dup
    end

    after do
      OmniAuth.config.camelizations = @old_camelizations
    end

    it 'works on normal cases' do
      {
        'some_word' => 'SomeWord',
        'AnotherWord' => 'AnotherWord',
        'one' => 'One',
        'three_words_now' => 'ThreeWordsNow'
      }.each_pair { |k, v| expect(OmniAuth::Utils.camelize(k)).to eq(v) }
    end

    it 'works on symbols' do
      expect(OmniAuth::Utils.camelize(:some_word)).to eq('SomeWord')
      expect(OmniAuth::Utils.camelize(:some_word, false)).to eq('someWord')
    end

    it 'works in special cases that have been added' do
      OmniAuth.config.add_camelization('oauth', 'OAuth')
      expect(OmniAuth::Utils.camelize(:oauth)).to eq('OAuth')
      expect(OmniAuth::Utils.camelize('oauth_two')).to eq('OauthTwo')
    end

    it 'doesn\'t uppercase the first letter when passed false' do
      expect(OmniAuth::Utils.camelize('apple_jack', false)).to eq('appleJack')
    end

    it 'returns an empty string for an empty word' do
      expect(OmniAuth::Utils.camelize('')).to eq('')
      expect(OmniAuth::Utils.camelize('', false)).to eq('')
    end

    it 'replaces / with ::' do
      expect(OmniAuth::Utils.camelize('apple_jack/cereal')).to eq('AppleJack::Cereal')
      expect(OmniAuth::Utils.camelize('apple_jack/cereal', false)).to eq('appleJack::Cereal')
      expect(OmniAuth::Utils.camelize('a/b/c')).to eq('A::B::C')
      expect(OmniAuth::Utils.camelize('apple/')).to eq('Apple::')
    end
  end
end
