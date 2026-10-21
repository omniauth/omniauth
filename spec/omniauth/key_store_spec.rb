require 'helper'

RSpec.describe OmniAuth::KeyStore do
  subject(:store) { described_class.new(:name => 'Fry', 'info' => {:email => 'fry@planetexpress.com'}) }

  it 'is a Hash' do
    expect(store).to be_a(Hash)
  end

  it 'is empty without a source' do
    expect(described_class.new).to eq({})
  end

  it 'converts its subclasses into themselves by default' do
    subclass = Class.new(described_class)
    expect(subclass.new(:a => {:b => 1})['a']).to be_instance_of(subclass)
  end

  it 'converts nested hashes into its subkey_class' do
    subclass = Class.new(described_class) do
      def self.subkey_class
        OmniAuth::KeyStore
      end
    end
    expect(subclass.new(:a => {:b => 1})['a']).to be_instance_of(described_class)
  end

  it 'passes the string key to convert_value' do
    subclass = Class.new(described_class) do
      def convert_value(key, value)
        key.eql?('tagged') ? [key, value] : super
      end
    end
    expect(subclass.new(:tagged => 1)['tagged']).to eq(['tagged', 1])
  end

  describe 'keys' do
    it 'stores symbol keys as strings' do
      expect(store.keys).to eq(%w[name info])
    end

    it 'leaves other keys alone' do
      expect(described_class.new(1 => 'one').keys).to eq([1])
    end

    it 'reads with string or symbol keys' do
      expect([store[:name], store['name']]).to eq(%w[Fry Fry])
    end

    it 'writes with string or symbol keys' do
      store[:name] = 'Leela'
      store.store(:age, 30)
      expect(store).to eq('name' => 'Leela', 'info' => {'email' => 'fry@planetexpress.com'}, 'age' => 30)
    end

    it 'fetches with symbol keys' do
      expect(store.fetch(:name)).to eq('Fry')
      expect(store.fetch(:missing, 'default')).to eq('default')
      expect(store.fetch(:missing) { |key| "no #{key}" }).to eq('no missing')
    end

    it 'deletes with symbol keys' do
      expect(store.delete(:name)).to eq('Fry')
      expect(store.delete(:name) { |key| "no #{key}" }).to eq('no name')
      expect(store.keys).to eq(%w[info])
    end

    it 'checks for keys with symbol keys' do
      expect(%i[key? has_key? include? member?].collect { |method| store.public_send(method, :name) }).to eq([true] * 4)
      expect(store.key?(:missing)).to be(false)
    end

    it 'digs with symbol keys' do
      expect(store.dig(:info, :email)).to eq('fry@planetexpress.com')
    end

    it 'reads several values with symbol keys' do
      expect(store.values_at(:name, 'info', :missing)).to eq(['Fry', {'email' => 'fry@planetexpress.com'}, nil])
    end
  end

  describe 'nested values' do
    it 'converts nested hashes' do
      expect(store['info']).to be_instance_of(described_class)
    end

    it 'converts hashes in arrays, at any depth' do
      store[:emails] = [{:primary => true}, [{:primary => false}], 'plain']
      expect(store.emails.first).to be_instance_of(described_class)
      expect(store.emails[1].first.primary?).to be(false)
      expect(store.emails.last).to eq('plain')
    end

    it 'keeps a KeyStore it is given as it is' do
      info = described_class.new(:email => 'leela@planetexpress.com')
      store.info = info
      expect(store.info).to be(info)
    end

    it 'keeps an instance of a KeyStore subclass as it is' do
      info = Class.new(described_class).new(:email => 'leela@planetexpress.com')
      store.info = info
      expect(store.info).to be(info)
    end

    it 'copies a hash it is given' do
      hash = {:email => 'leela@planetexpress.com'}
      store.info = hash
      store.info.email = 'changed'
      expect(hash).to eq(:email => 'leela@planetexpress.com')
    end
  end

  describe 'method access' do
    it 'reads keys' do
      expect(store.info.email).to eq('fry@planetexpress.com')
    end

    it 'reads a missing key as nil' do
      expect(store.missing).to be_nil
    end

    it 'writes keys' do
      store.info.phone = '555-1234'
      expect(store['info']['phone']).to eq('555-1234')
    end

    it 'converts written hashes' do
      store.extra = {:raw_info => {:id => 1}}
      expect(store.extra.raw_info.id).to eq(1)
    end

    it 'checks keys with ?' do
      store[:off] = false
      expect([store.name?, store.missing?, store.off?]).to eq([true, false, false])
    end

    it 'responds to methods for its keys and any writer or predicate' do
      expect(store).to respond_to(:name)
      expect(store).to respond_to(:anything=)
      expect(store).to respond_to(:anything?)
      expect(store).not_to respond_to(:anything)
    end

    it 'still uses real methods' do
      expect(store.keys).to eq(%w[name info])
    end
  end

  describe 'merging' do
    it 'updates in place, converting keys and values' do
      expect(store.update(:age => 30, :info => {:phone => '555'})).to be(store)
      expect(store).to eq('name' => 'Fry', 'info' => {'phone' => '555'}, 'age' => 30)
      expect(store.info).to be_instance_of(described_class)
    end

    it 'aliases merge! to update' do
      store.merge!(:age => 30)
      expect(store.age).to eq(30)
    end

    it 'merges into a copy' do
      merged = store.merge(:age => 30)
      expect(merged).to be_instance_of(described_class)
      expect(merged.age).to eq(30)
      expect(store.key?(:age)).to be(false)
    end

    it 'deep merges nested hashes in place' do
      store.deep_merge!(:info => {:phone => '555'}, :name => 'Leela')
      expect(store).to eq('name' => 'Leela', 'info' => {'email' => 'fry@planetexpress.com', 'phone' => '555'})
    end

    it 'replaces a non-hash value when deep merging' do
      store.deep_merge!(:name => {:first => 'Philip'}, :info => 'none')
      expect(store).to eq('name' => {'first' => 'Philip'}, 'info' => 'none')
      expect(store.name).to be_instance_of(described_class)
    end

    it 'deep merges KeyStores into nested KeyStore subclasses' do
      subclass = Class.new(described_class)
      options = subclass.new(:client => {:site => 'https://example.com'})
      options.deep_merge!(:client => described_class.new(:scope => 'email'))
      expect(options.client).to eq('site' => 'https://example.com', 'scope' => 'email')
      expect(options.client).to be_instance_of(subclass)
    end

    it 'aliases deep_update to deep_merge!' do
      store.deep_update(:info => {:phone => '555'})
      expect(store.info.email).to eq('fry@planetexpress.com')
    end

    it 'deep merges into a copy' do
      merged = store.deep_merge(:info => {:phone => '555'})
      expect(merged.info).to eq('email' => 'fry@planetexpress.com', 'phone' => '555')
      expect(store.info.key?(:phone)).to be(false)
    end
  end

  describe '#dup' do
    it 'copies nested KeyStores' do
      copy = store.dup
      copy.info.email = 'changed'
      expect(store.info.email).to eq('fry@planetexpress.com')
      expect(copy).to be_instance_of(described_class)
    end

    it 'copies nested KeyStore subclasses' do
      store.info = Class.new(described_class).new(:email => 'leela@planetexpress.com')
      expect(store.dup.info).not_to be(store.info)
    end

    it 'keeps the same values that are not KeyStores' do
      copy = store.dup
      expect(copy['name']).to be(store['name'])
    end
  end

  describe 'subsets' do
    it 'selects into the same class' do
      selected = store.select { |_, value| value == 'Fry' }
      expect(selected).to be_instance_of(described_class)
      expect(selected).to eq('name' => 'Fry')
    end

    it 'rejects into the same class' do
      rejected = store.reject { |_, value| value == 'Fry' }
      expect(rejected).to be_instance_of(described_class)
      expect(rejected.keys).to eq(%w[info])
    end

    it 'slices with symbol keys into the same class' do
      sliced = store.slice(:name)
      expect(sliced).to be_instance_of(described_class)
      expect(sliced).to eq('name' => 'Fry')
    end

    it 'excepts symbol keys into the same class' do
      excepted = store.except(:name)
      expect(excepted).to be_instance_of(described_class)
      expect(excepted.keys).to eq(%w[info])
    end
  end

  describe '#to_hash' do
    before { store[:emails] = [{:primary => true}, 'plain'] }

    it 'converts to plain nested hashes with string keys' do
      hash = store.to_hash
      expect(hash).to eq('name' => 'Fry', 'info' => {'email' => 'fry@planetexpress.com'}, 'emails' => [{'primary' => true}, 'plain'])
      expect([hash.class, hash['info'].class, hash['emails'].first.class]).to eq([Hash] * 3)
    end

    it 'symbolizes keys at every level when asked' do
      expect(store.to_hash(:symbolize_keys => true)).to eq(:name => 'Fry', :info => {:email => 'fry@planetexpress.com'}, :emails => [{:primary => true}, 'plain'])
    end
  end
end
