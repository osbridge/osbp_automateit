# Setup RedMine

sitename = "bridgepdx_redmine"
docroot = "/var/www/#{sitename}"
mkdir_p(docroot) && chown(default_user, default_group, docroot, :recursive => true)

modified = apache_manager.install_site(sitename)
apache_manager.reload if modified

# Add task to import emails and dump database to file
cronedit(default_user) do
  append "19 * * * * if test -f /var/www/bridgepdx_redmine/current/Rakefile; then (cd /var/www/bridgepdx_redmine/current && rake RAILS_ENV=production --silent db:raw:dump FILE=/var/www/bridgepdx_redmine/shared/db/production.sql); fi"
  delete /rake redmine:my:getemails/
end
