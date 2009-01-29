# Setup OpenConferenceWare

# Gems
package_manager.install %w[mbleigh-acts-as-taggable-on right_aws thoughtbot-paperclip ruby-openid RedCloth], :with => :gem, :docs => false

# Variables
user = "bridgepdx"
sitename = "bridgepdx_ocw"
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
