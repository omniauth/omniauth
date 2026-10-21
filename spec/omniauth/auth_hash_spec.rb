require 'helper'

describe OmniAuth::AuthHash do
  subject { OmniAuth::AuthHash.new }
  it 'converts a supplied info key into an InfoHash object' do
    subject.info = {:first_name => 'Awesome'}
    expect(subject.info).to be_kind_of(OmniAuth::AuthHash::InfoHash)
    expect(subject.info.first_name).to eq('Awesome')
  end

  it 'keeps a supplied InfoHash as is' do
    info = OmniAuth::AuthHash::InfoHash.new(:name => 'Awesome')
    subject.info = info
    expect(subject.info).to equal(info)
  end

  it 'keeps a supplied InfoHash subclass as is' do
    info = Class.new(OmniAuth::AuthHash::InfoHash).new(:name => 'Awesome')
    subject.info = info
    expect(subject.info).to equal(info)
  end

  it 'converts info written with a symbol key' do
    subject[:info] = {:first_name => 'Awesome'}
    expect(subject['info']).to be_instance_of(OmniAuth::AuthHash::InfoHash)
  end

  it 'does not try to parse `string` as InfoHash' do
    subject.weird_field = {:info => 'string'}
    expect(subject.weird_field.info).to eq 'string'
  end

  it 'has a subkey_class' do
    expect(OmniAuth::AuthHash.subkey_class).to eq OmniAuth::KeyStore
  end

  it 'converts other nested hashes into plain KeyStores' do
    auth = OmniAuth::AuthHash.new(:credentials => {:token => 'abc'})
    expect(auth.credentials).to be_instance_of(OmniAuth::KeyStore)
  end

  it 'converts a supplied KeyStore info into an InfoHash' do
    subject.info = OmniAuth::KeyStore.new(:name => 'Awesome')
    expect(subject.info).to be_instance_of(OmniAuth::AuthHash::InfoHash)
  end

  it 'keeps a nil info' do
    expect(OmniAuth::AuthHash.new(:info => nil).info).to be_nil
  end

  it 'keeps an info that is not a hash' do
    expect(OmniAuth::AuthHash.new(:info => 'none').info).to eq('none')
  end

  describe '#valid?' do
    subject { OmniAuth::AuthHash.new(:uid => '123', :provider => 'example', :info => {:name => 'Steven'}) }

    it 'is valid with the right parameters' do
      expect(subject.valid?).to be(true)
    end

    it 'requires an info hash' do
      expect(OmniAuth::AuthHash.new(:uid => '123', :provider => 'example').valid?).to be(false)
    end

    it 'requires a uid' do
      subject.uid = nil
      expect(subject).not_to be_valid
    end

    it 'requires a provider' do
      subject.provider = nil
      expect(subject).not_to be_valid
    end

    it 'requires a name in the user info hash' do
      subject.info.name = nil
      expect(subject).not_to be_valid
    end
  end

  describe '#name' do
    subject do
      OmniAuth::AuthHash.new(:info => {
                               :name => 'Phillip J. Fry',
                               :first_name => 'Phillip',
                               :last_name => 'Fry',
                               :nickname => 'meatbag',
                               :email => 'fry@planetexpress.com'
                             })
    end

    it 'defaults to the name key' do
      expect(subject.info.name).to eq('Phillip J. Fry')
    end

    it 'falls back to go to first_name last_name concatenation' do
      subject.info.name = nil
      expect(subject.info.name).to eq('Phillip Fry')
    end

    it 'displays only a first or last name if only that is available' do
      subject.info.name = nil
      subject.info.first_name = nil
      expect(subject.info.name).to eq('Fry')
    end

    it 'displays only the first name if the last name is not available' do
      subject.info.name = nil
      subject.info.last_name = nil
      expect(subject.info.name).to eq('Phillip')
    end

    it 'displays the nickname if no name, first, or last is available' do
      subject.info.name = nil
      %w[first_name last_name].each { |k| subject.info[k] = nil }
      expect(subject.info.name).to eq('meatbag')
    end

    it 'displays the email if no name, first, last, or nick is available' do
      subject.info.name = nil
      %w[first_name last_name nickname].each { |k| subject.info[k] = nil }
      expect(subject.info.name).to eq('fry@planetexpress.com')
    end

    it 'is nil if no name, first, last, nick, or email is available' do
      %w[name first_name last_name nickname email].each { |k| subject.info[k] = nil }
      expect(subject.info.name).to be_nil
    end

    it 'is nil if the email is false' do
      %w[name first_name last_name nickname].each { |k| subject.info[k] = nil }
      subject.info.email = false
      expect(subject.info.name).to be_nil
    end
  end

  describe '#to_hash' do
    subject { OmniAuth::AuthHash.new(:uid => '123', :provider => 'test', :name => 'Example User') }
    let(:hash) { subject.to_hash }

    it 'is a plain old hash' do
      expect(hash.class).to eq(Hash)
    end

    it 'has string keys' do
      expect(hash.keys).to be_include('uid')
    end

    it 'converts an info hash as well' do
      subject.info = {:first_name => 'Example', :last_name => 'User'}
      expect(subject.info.class).to eq(OmniAuth::AuthHash::InfoHash)
      expect(subject.to_hash['info'].class).to eq(Hash)
    end

    it 'supplies the calculated name in the converted hash' do
      subject.info = {:first_name => 'Examplar', :last_name => 'User'}
      expect(hash['info']['name']).to eq('Examplar User')
    end

    it "does not pollute the URL hash with 'name' etc" do
      subject.info = {'urls' => {'Homepage' => 'http://homepage.com'}}
      expect(subject.to_hash['info']['urls']).to eq('Homepage' => 'http://homepage.com')
    end
  end

  describe OmniAuth::AuthHash::InfoHash do
    describe '#valid?' do
      it 'is valid if there is a name' do
        expect(OmniAuth::AuthHash::InfoHash.new(:name => 'Awesome').valid?).to be(true)
      end
    end

    describe '#name?' do
      it 'is true if a name can be calculated' do
        expect(OmniAuth::AuthHash::InfoHash.new(:first_name => 'Awesome').name?).to be(true)
      end

      it 'is false if no name can be calculated' do
        expect(OmniAuth::AuthHash::InfoHash.new(:image => 'awesome.png').name?).to be(false)
      end
    end

    it 'has a subkey_class' do
      expect(OmniAuth::AuthHash::InfoHash.subkey_class).to eq OmniAuth::KeyStore
    end

    describe 'subsets' do
      let(:info) { OmniAuth::AuthHash::InfoHash.new(:email => 'fry@planetexpress.com', :nickname => 'meatbag') }

      it 'does not add a calculated name to a slice' do
        expect(info.slice(:email).to_hash).to eq('email' => 'fry@planetexpress.com')
      end

      it 'does not add a calculated name to an except', :if => Hash.method_defined?(:except) do
        expect(info.except(:nickname).to_hash).to eq('email' => 'fry@planetexpress.com')
      end

      it 'does not add a calculated name to a select' do
        expect(info.select { |_, value| value.include?('@') }.to_hash).to eq('email' => 'fry@planetexpress.com')
      end

      it 'does not add a calculated name to a reject' do
        expect(info.reject { |key, _| key == 'nickname' }.to_hash).to eq('email' => 'fry@planetexpress.com')
      end

      it 'still adds a calculated name to the full hash' do
        expect(info.to_hash['name']).to eq('meatbag')
      end

      it 'adds a calculated name under a symbol key when symbolizing keys' do
        expect(info.to_hash(:symbolize_keys => true)).to eq(:email => 'fry@planetexpress.com', :nickname => 'meatbag', :name => 'meatbag')
      end
    end
  end
end
