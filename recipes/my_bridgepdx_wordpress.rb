# Setup bridgepdx.org WordPress
# DEPENDS ON:
# - base_php.rb
# - base_mysql.rb
# - my_reown.rb
# - my_bridgepdx_user.rb

# Variables
user = "bridgepdx"
sitename = "bridgepdx.org-wordpress"
docroot = "/var/www/#{sitename}"
site_available = "/etc/apache2/sites-available/#{sitename}"
site_enabled = "/etc/apache2/sites-enabled/#{sitename}"

# Setup directory
mkdir_p(docroot) && chown(user, user, docroot, :recursive => true)
system("/usr/local/bin/reown -q") unless preview?

# Setup apache
modified = false
modified |=  cp dist+site_available, site_available, :user => 'root', :group => 'root', :mode => 0444
modified |= ln_sf site_available, site_enabled

# Reload apache if needed
service_manager.tell("apache", "force-reload") if modified
