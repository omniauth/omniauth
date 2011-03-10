require 'omniauth/identity'

module OmniAuth
  module Strategies
    class Identity
      include OmniAuth::Strategy

      def initialize(app, options = {}, &block)
        options[:key] ||= 'nickname'
        super(app, :identity, options, &block) 
      end

      def request_phase
        OmniAuth::Form.build(:title => (self.options[:title] || 'Identify Yourself'), :url => callback_path) do
          text_field 'Login', 'key' 
          password_field 'Password', 'password'

          html <<-HTML
            <a id='toggle_register' href='javascript:document.getElementById("toggle_register").style.display="none";document.getElementById("register").style.display = "block"'>Create a New Identity</a>
          HTML

          fieldset("Create Identity", :id => 'register', :style => 'display:none;') do
            password_field 'Repeat Password', 'register[password_confirmation]'
            text_field 'E-Mail', 'register[email]'
            text_field 'Name', 'register[name]'
          end        
        end.to_response
      end
      
      def callback_phase
        if auth_hash
          super
        else
          fail!(:invalid_credentials)
        end
      end

      def auth_hash
        @hash ||= OmniAuth::Identity::Model.identify(options[:key],request.params['key'],request.params['password'])
      end
    end
  end
end
