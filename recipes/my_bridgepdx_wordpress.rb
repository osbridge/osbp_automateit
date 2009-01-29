# Setup bridgepdx.org WordPress
# DEPENDS ON:
# - base_php.rb
# - base_mysql.rb
# - my_reown.rb
# - my_bridgepdx_user.rb

=begin
# Instructions for migration:

## Dump existing database to file
mysqldump --add-locks --create-options --disable-keys --extended-insert --quick --set-charset --user=wordpress wordpress > /tmp/wordpress.sql

## Create new database, grant rights, and specify hostname via mysql
create database bridgepdx_wordpress;
grant all on bridgepdx_wordpress.* to 'bridgepdx'@'localhost' identified by 'FIXME';

# Restore database
mysql bridgepdx_wordpress < /tmp/wordpress.sql

# Fix urls via mysql
use bridgepdx_wordpress;
update wp_options set option_value='http://FIXME/' where option_name='siteurl';
update wp_options set option_value='http://FIXME/' where option_name='home';

# Fix configuration
wp-config.php
=end

# Variables
user = "bridgepdx"
sitename = "bridgepdx_wordpress"
docroot = "/var/www/#{sitename}"
site_available = "/etc/apache2/sites-available/#{sitename}"
site_enabled = "/etc/apache2/sites-enabled/#{sitename}"

# Setup directory
mkdir_p(docroot) && chown(user, user, docroot, :recursive => true)
system("/usr/local/bin/reown -q") unless preview?

# Setup apache
modified = false
modified |=  render(dist+site_available+'.erb', site_available, :user => 'root', :group => 'root', :mode => 0444)
modified |= ln_sf site_available, site_enabled

# Reload apache if needed
service_manager.tell("apache", "force-reload") if modified

# FIXME Enable modules: proxy proxy_http
