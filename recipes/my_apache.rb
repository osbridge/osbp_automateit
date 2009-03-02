# Setup additional Apache features

# Apache modules to enable
mods = %w[
  vhost_alias
  rewrite
  deflate
  headers
  expires
]

#-----------------------------------------------------------------------

# Enable modules
mods.each do |mod|
  %w[conf load].each do |ext|
    source = "/etc/apache2/mods-available/#{mod}.#{ext}"
    target = "/etc/apache2/mods-enabled/#{mod}.#{ext}"
    if File.exist?(source)
      ln_s source, target
    end
  end
end
#
# Setup default site
sitename = "default"
site_available = "/etc/apache2/sites-available/#{sitename}"
site_enabled = "/etc/apache2/sites-enabled/#{sitename}"
modified = false
modified |=  cp dist+site_available, site_available, :user => 'root', :group => 'root', :mode => 0444
# Don't symlink because default is already linked as 000-default

# Reload apache if needed
service_manager.tell("apache", "force-reload") if modified
