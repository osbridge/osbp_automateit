# Setup etherpad

user = "bridgepdx"
sitename = "bridgepdx_etherpad"
docroot = "/var/www/#{sitename}"
mkdir_p(docroot) && chown(user, user, docroot, :recursive => true)

modified = apache_manager.install_site(sitename)
apache_manager.reload if modified

# Add task to import emails and dump database to file
edit("/var/spool/cron/crontabs/#{user}", :create => true, :user => user, :group => "crontab", :mode => 0600) do
  append "# m h  dom mon dow   command"
  # FIXME temporarily disable these because the production server has too little memory to handle Etherpad :(
  # Start the server on boot
  delete "@reboot if test -f /var/www/bridgepdx_etherpad/Rakefile; then cd /var/www/bridgepdx_etherpad; rake --silent start; fi"
  # Backup the database to a file
  delete "20 * * * * if test -f /var/www/bridgepdx_etherpad/Rakefile; then cd /var/www/bridgepdx_etherpad; rake --silent backup; fi"
end

