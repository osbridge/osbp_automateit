# Setup RedMine

user = "bridgepdx"
sitename = "bridgepdx_redmine"
docroot = "/var/www/#{sitename}"
mkdir_p(docroot) && chown(user, user, docroot, :recursive => true)

modified = apache_manager.install_site(sitename)
apache_manager.reload if modified

# Add task to import emails and dump database to file
edit("/var/spool/cron/crontabs/#{user}", :create => true, :user => user, :group => "crontab", :mode => 0600) do
  append "# m h  dom mon dow   command"
  delete "*/1 * * * * if test -f /var/www/bridgepdx_redmine/current/Rakefile; then (cd /var/www/bridgepdx_redmine/current && rake redmine:my:getemails RAILS_ENV=production); fi"
  append "*/1 * * * * if test -f /var/www/bridgepdx_redmine/current/Rakefile; then (cd /var/www/bridgepdx_redmine/current && rake redmine:my:getemails --silent RAILS_ENV=production); fi"
  append "19 * * * * if test -f /var/www/bridgepdx_redmine/current/Rakefile; then (cd /var/www/bridgepdx_redmine/current && rake RAILS_ENV=production --silent db:raw:dump FILE=/var/www/bridgepdx_redmine/shared/db/production.sql); fi"
end
