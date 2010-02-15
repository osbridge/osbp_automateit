# Setup attendee wiki.
# NOTE Apache site is managed by the 'my_bridgepdx_wordpress' recipe.

# Create directory
sitedir = "/var/www/bridgepdx_wiki"
mkdir_p(sitedir) and chperm(sitedir, :user => default_user, :group => default_group)

# Add task to dump database to file
cronedit(default_user) do
  append "# m h  dom mon dow   command"
  delete "17 * * * * (cd #{sitedir} && rake --silent dump)"
  delete "18 * * * * if test -f #{sitedir}/Rakefile; then (cd #{sitedir} && rake --silent dump); fi"
  append "18 * * * * if test -f #{sitedir}/LocalSettings.php; then (cd #{sitedir} && rake --silent dump); fi"
end
