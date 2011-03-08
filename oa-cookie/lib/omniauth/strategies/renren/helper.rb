module OmniAuth
  module Strategies
    class Renren
      module Helper
        def omniauth_renren_connect_button
          callback_path = "#{OmniAuth.config.path_prefix}/renren/callback"
          @renren_connect_form_id = 'omniauth_renren_connect_form'

          if defined?(::ActionView::Helpers::FormTagHelper)

            form_tag(callback_path, :id => @renren_connect_form_id) do
              renren_connect_button.html_safe
            end
          else

            <<-HTML
<form accept-charset="UTF-8" action="#{callback_path}" id="#{@renren_connect_form_id}" method="post">
#{renren_connect_button}
</form>
            HTML
          end
        end
        
        def omniauth_simple_renren_connect_button(options = {})
          params = {
            :src => "http://pics.wanlibo.com/images_cn/registration/renren.png",
            :title => "renren connect",
            :alt => "renren connect"
          }.merge(options)
          
          p = ""
          params.each do |k, v|
            p += k.to_s + "='" + v + "' "
          end
          simple_renren_connect_button(p).html_safe
        end
        
        def omniauth_renren_friends(options = {})
          params = {
            :max_rows => "2",
            :face_space => "5",
            :width => "217"
          }.merge(options)
          renren_friends(params).html_safe
        end
        
        def omniauth_renren_live_widget(options = {})
          params = {
            :width => "370px",
            :height => "390px"
          }.merge(options)
          renren_live_widget(params).html_safe
        end
        
        def omniauth_renren_like_button(options = {})
          params = {
            :width => "200px",
            :height => "70px",
            :url => root_url
          }.merge(options)
          renren_like_button(params).html_safe
        end

        def omniauth_renren_invite(options = {})
          params = {
            :content => "Join us",
            :url1 => "http://www.renren.com",
            :label1 => "Go",
            :url2 => "http://apps.renren.com/yourapp",
            :label2 => "Accept",
            :action => "/yourapp/youraction",
            :friend_text => "Invite your friends",
            :max => "5",
            :mode => "all"
          }.merge(options)
          renren_invite(params).html_safe
        end

        private
        
        def renren_invite(options)
          <<-HTML
<xn:serverxnml>
<script type="text/xnml">
<xn:request-form content="#{options[:content]} &lt;xn:req-choice url=&quot;#{options[:url1]}&quot; label=&quot;#{options[:label1]}&quot;&gt;&lt;xn:req-choice url=&quot;#{options[:url2]}&quot; label=&quot;#{options[:label2]}&quot;&gt;" action="#{options[:action]}">
<xn:multi-friend-selector-x actiontext="#{options[:friend_text]}" max="#{options[:max]}" mode="#{options[:mode]}"/>
</xn:request-form></script></xn:serverxnml>
#{renren_javascript}
          HTML
        end
        
        def renren_like_button(options = {})
          <<-HTML
<iframe scrolling="no" frameborder="0" allowtransparency="true" src="http://www.connect.renren.com/like?url=#{options[:url]}" style="width: #{options[:width]};height: #{options[:height]};"></iframe>
#{renren_javascript}
          HTML
        end
        
        def renren_live_widget(options = {})
          <<-HTML
<iframe scrolling="no" frameborder="0" src="http://www.connect.renren.com/widget/liveWidget?api_key=#{Renren.api_key}&xid=default&desp=%E5%A4%A7%E5%AE%B6%E6%9D%A5%E8%AE%A8%E8%AE%BA" style="width: #{options[:width]};height: #{options[:height]};"></iframe>
#{renren_javascript}
          HTML
        end
        
        def renren_friends(options = {})
          <<-HTML
<xn:friendpile show-faces="all" face-size="small" max-rows="#{options[:max_rows]}" face-space="#{options[:face_space]}" width="#{options[:width]}"></xn:friendpile>
#{renren_javascript}
          HTML
        end
        
        def simple_renren_connect_button(properties)
          callback_path = "#{OmniAuth.config.path_prefix}/renren/callback"
          <<-HTML
<img #{properties} onclick="XN.Connect.requireSession(function(){window.location.href='#{callback_path}';});return false;"></img>        
#{renren_javascript}
          HTML
        end
        
        def renren_connect_button
          <<-HTML
<xn:login-button autologoutlink="true" onlogin="document.getElementById('#{@renren_connect_form_id}').submit();"></xn:login-button>
#{renren_javascript}
          HTML
        end

        def renren_javascript
          <<-HTML      
<script src="http://static.connect.renren.com/js/v1.0/FeatureLoader.jsp" type="text/javascript"></script>
<script type="text/javascript">
  //<![CDATA[
  XN_RequireFeatures(['EXNML'], function(){ XN.Main.init('#{Renren.api_key}', '/xd_receiver.html'); });
  //]]>
</script>
          HTML
        end
      end
    end
  end
end
