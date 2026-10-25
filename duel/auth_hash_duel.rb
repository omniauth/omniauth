require_relative 'duel_helper'

# The auth hash that every callback builds, and that the app reads, often
# field by field, and stores with #to_hash.

duel 'auth_hash: build a minimal one' do
  OmniAuth::AuthHash.new(:provider => 'github', :uid => '42')
end

duel 'auth_hash: build a typical one' do
  once { @data = DuelHelper.auth_data }
  OmniAuth::AuthHash.new(@data)
end

# A raw_info with far more fields than providers usually send (GitHub's
# has about 30), some of them nested.
duel 'auth_hash: build one with a large raw_info' do
  once { @data = DuelHelper.auth_data(DuelHelper.raw_info(200)) }
  OmniAuth::AuthHash.new(@data)
end

duel 'auth_hash: read its fields' do
  once { @auth = OmniAuth::AuthHash.new(DuelHelper.auth_data) }
  @auth.provider
  @auth.uid
  @auth.info.name
  @auth.info.email
  @auth.credentials.token
  @auth.extra.raw_info.login
  @auth.valid?
end

# The name, made from first and last names, which some providers send
# without a name.
duel 'auth_hash: a name from first and last names' do
  once { @info = OmniAuth::AuthHash::InfoHash.new('first_name' => 'Ada', 'last_name' => 'Lovelace', 'email' => 'ada@example.org') }
  @info.name
end

duel 'auth_hash: to_hash' do
  once { @auth = OmniAuth::AuthHash.new(DuelHelper.auth_data) }
  @auth.to_hash
end
