# Setup bridgepdx.org WordPress
# DEPENDS ON:
# - base_php.rb
# - base_mysql.rb
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
sitename = "bridgepdx_wordpress"
docroot = "/var/www/#{sitename}"

# Setup directory
mkdir_p(docroot) && chown(default_user, default_group, docroot, :recursive => true)

# Setup apache
modified = apache_manager.install_site(sitename, :template => true)

# Reload apache if needed
apache_manager.reload if modified

# Add program that can dump database to file
cpdist("/var/www/bridgepdx_wordpress/Rakefile")

# Add task to dump database to file
edit("/var/spool/cron/crontabs/#{default_user}", :create => true, :user => default_user, :group => "crontab", :mode => 0600) do
  append "# m h  dom mon dow   command"
  delete "17 * * * * if test -f /var/www/bridgepdx_wordpress/Rakefile; then (cd /var/www/bridgepdx_wordpress && rake --silent dump); fi"
  append "17 * * * * if test -f /var/www/bridgepdx_wordpress/wp-config.php; then (cd /var/www/bridgepdx_wordpress && rake --silent dump); fi"
end
