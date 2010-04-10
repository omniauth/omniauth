module OmniAuth
  module Strategies
    # An Authentication strategy that utilizes Facebook Connect.
    class Facebook
      include OmniAuth::Strategy
      EXTENDED_PERMISSIONS = %w(publish_stream read_stream email read_mailbox offline_access create_event rsvp_event sms status_update video_upload create_note share_item)
      
      # Initialize the middleware. Requires a Facebook API key and secret 
      # and takes the following options:
      #
      # <tt>:permissions</tt> :: An array of Facebook extended permissions, defaults to <tt>%w(email offline_access)</tt>. Use <tt>:all</tt> to include all extended permissions.
      # <tt>:scripts</tt> :: A boolean value for whether or not to automatically inject the Facebook Javascripts and XD Receiver into your application. Defaults to <tt>true</tt>.
      #
      def initialize(app, api_key, api_secret, options = {})
        super app, :facebook
        
        options[:permissions] = EXTENDED_PERMISSIONS if options[:permissions] == :all
        @options = {
          :permissions => %w(email offline_access),
          :scripts => true
        }.merge(options)

        @api_key = api_key
        @api_secret = api_secret
        
        self.extend PageInjections if @options[:scripts]
      end
      
      def auth_hash
        OmniAuth.deep_merge(super, {
          'provider' => 'facebook',
          'uid' => request.cookies["#{@api_key}_user"],
          'credentials' => {
            'key' => request.cookies["#{@api_key}_session_key"],
            'secret' => request.cookies["#{@api_key}_ss"],
            'expires' => (Time.at(request.cookies["#{@api_key}_expires"].to_i) if request.cookies["#{@api_key}_expires"].to_i > 0)
          },
          'user_info' => user_info(session_key, user_id)
        })
      end
      
      def user_info
        hash = MiniFB.call(@api_key, @api_secret, "Users.getInfo", 'uids' => request[:auth][:user_id], 'fields' => [:name, :first_name, :last_name, :username, :pic_square, :current_location])[0]
        {
          'name' => user[:name],
          'first_name' => user[:first_name],
          'last_name' => user[:last_name],
          'nickname' => user[:username],
          'image' => user[:pic_square],
          'location' => user[:locale]
        }
      end
      
      def call(env)
        dup = self.dup
        dup.extend PageInjections if @options[:scripts]
        dup.call!(env)
      end

      module PageInjections
        def call!(env)
          super
          @base_url = (request.scheme.downcase == 'https' ? 'https://ssl.connect.facebook.com' : 'http://static.ak.connect.facebook.com')
          case request.path
            when "/#{OmniAuth.config.path_prefix}/facebook/xd_receiver.html"
              xd_receiver
            else
              inject_facebook
          end
        end

        def xd_receiver #:nodoc:
          xd = <<-HTML
          <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
             "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
          <html xmlns="http://www.w3.org/1999/xhtml" >
          <head>
              <title>Cross-Domain Receiver Page</title>
          </head>
          <body>
              <script src="#{@base_url}/js/api_lib/v0.4/XdCommReceiver.js" type="text/javascript"></script>
          </body>
          </html>
          HTML

          Rack::Response.new(xd).finish
        end
        
        def inject_facebook #:nodoc:
          status, headers, responses = @app.call(@env)
          responses = Array(responses) unless responses.respond_to?(:each)

          if headers["Content-Type"] =~ %r{(text/html)|(application/xhtml+xml)}
            resp = []
            responses.each do |r|
              r.sub! /(<html[^\/>]*)>/i, '\1 xmlns:fb=\"http://www.facebook.com/2008/fbml\">'
              r.sub! /(<body[^\/>]*)>/i, '\1><script src="' + @base_url + '/js/api_lib/v0.4/FeatureLoader.js.php/en_US" type="text/javascript"></script>'
              r.sub! /<\/body>/i, <<-HTML
                <script type="text/javascript">
                  FB.init("#{@api_key}", "/auth/facebook/xd_receiver.html");
                  OmniAuth = {
                    Facebook: {
                      loginSuccess:function() {
                        FB.Connect.showPermissionDialog("#{Array(@options[:permissions]).join(',')}", function(perms) {
                          if (perms) {
                            window.location.href = '/#{OmniAuth.config.path_prefix}/facebook/callback';
                          } else {
                            window.location.href = '/#{OmniAuth.config.path_prefix}/facebook/callback?permissions=denied';
                          }
                        });
                      },
                      loginFailure:function() {
                        window.location.href = '/#{OmniAuth.config.path_prefix}/failure?message=user_declined';
                      }
                    }
                  }
                </script></body>
              HTML
              resp << r
            end
          end

          Rack::Response.new(resp || responses, status, headers).finish
        end
      end
    end
  end
end