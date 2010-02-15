# Setup attendee wiki.
# NOTE Apache site is managed by the 'my_bridgepdx_wordpress' recipe.

# The app used to live at another directory
old_dir = "/var/www/bridgepdx_wiki"
sitedir = "/var/www/bridgepdx_wiki_2009"

# Move directory over if found
if mv(old_dir, sitedir)
  service_manager.tell "apache2", "reload"
end

# Create directory
mkdir_p(sitedir) and chperm(sitedir, :user => default_user, :group => default_group)

# Add task to dump database to file
cronedit(default_user) do
  append "# m h  dom mon dow   command"
  delete "17 * * * * (cd #{old_dir} && rake --silent dump)"
  delete "18 * * * * if test -f #{old_dir}/Rakefile; then (cd #{old_dir} && rake --silent dump); fi"
  delete "18 * * * * if test -f #{old_dir}/LocalSettings.php; then (cd #{old_dir} && rake --silent dump); fi"
  append "18 * * * * if test -f #{sitedir}/LocalSettings.php; then (cd #{sitedir} && rake --silent dump); fi"
end
