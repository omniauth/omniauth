require 'helper'

def mock_env
  {
    'rack.session' => {}
  }
end

describe OmniAuth::SessionStore do
  describe 'adding to the session' do
    subject { OmniAuth::SessionStore.new(mock_env) }
    let(:mock_params) { {"uid"=> "ID", "name" => "Paul"} }
    it 'can store items in the session' do
      subject["omniauth.params"]= mock_params
      expect(subject["omniauth.params"]).to eq(mock_params)
    end
  end
  
  describe 'delete from session' do
    subject { OmniAuth::SessionStore.new(mock_env) }
    let(:mock_params) { {"uid"=> "ID", "name" => "Paul"} }
    it 'can delete items from the session' do
      subject["omniauth.params"]= mock_params
      subject.delete("omniauth.params")
      expect(subject["omniauth.params"]).to be_nil
    end
  end
end