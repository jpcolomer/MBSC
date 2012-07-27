require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication
  def initialize
    # Tab items are loaded left->right, @tabs[0] is leftmost tab in the tab-bar
    # Super must be called *after* settings @tabs!
    @tabs = [
      { :label => "Inicio", :action => '/app', 
        :icon => "/public/images/tabs/53-house.png", :reload => true, :web_bkg_color => 0x7F7F7F }, 
      { :label => "Noticias",  :action => '/app/Account',  
        :icon => "/public/images/tabs/166-newspaper.png" },
      { :label => "Mi Pantalla",  :action => '/app/Contact',  
        :icon => "/public/images/tabs/32-iphone.png" },
      { :label => "Buscar",   :action => '/app/Message/search', 
        :icon => "/public/images/tabs/06-magnify.png", :reload => true }
    ]
    #To remove default toolbar uncomment next line:
    @@toolbar = nil
    super

    # Uncomment to set sync notification callback to /app/Settings/sync_notify.
    # SyncEngine::set_objectnotify_url("/app/Settings/sync_notify")
    SyncEngine.set_notification(-1, "/app/Settings/sync_notify", '')
  end
end
