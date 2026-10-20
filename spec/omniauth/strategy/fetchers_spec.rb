require 'helper'

# The top-level describe is OmniAuth::Strategy rather than
# OmniAuth::Strategy::Fetchers so mutant keeps selecting every
# OmniAuth::Strategy example for the Fetchers subjects.
describe OmniAuth::Strategy, 'fetchers' do
  let(:parent_class) do
    c = Class.new
    c.send(:include, OmniAuth::Strategy)
    c.uid { 'parent' }
    c
  end

  let(:strategy_class) do
    c = Class.new(parent_class)
    c.option :name, 'fetched'
    c.uid { "#{options[:name]}-uid" }
    c.info { {'name' => options[:name]} }
    c.credentials { {'token' => options[:name]} }
    c.extra { {'raw' => options[:name]} }
    c
  end

  let(:strategy) { strategy_class.new(nil) }

  it 'uses the uid from the most specific class and runs it on the instance' do
    expect(strategy.uid).to eq('fetched-uid')
  end

  it 'runs the info, credentials, and extra blocks on the instance' do
    expect([strategy.info, strategy.credentials, strategy.extra]).to eq([{'name' => 'fetched'}, {'token' => 'fetched'}, {'raw' => 'fetched'}])
  end

  it 'builds the auth hash with the strategy name as the provider' do
    expect(strategy.auth_hash.provider).to eq('fetched')
  end

  it 'is not skipping info when the skip_info callable is falsy for the uid' do
    strategy = strategy_class.new(nil, :skip_info => lambda { |uid| uid == 'other-uid' })
    expect(strategy).not_to be_skip_info
  end
end
