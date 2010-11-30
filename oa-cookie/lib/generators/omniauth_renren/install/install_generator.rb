module OmniauthRenren
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_files
      copy_file 'public/xd_receiver.html'
    end

    def include_helper
      inject_into_file 'app/helpers/application_helper.rb', :after => "module ApplicationHelper\n" do
        "  include OmniAuth::Strategies::Renren::Helper\n"
      end
    end
  end
end
