# Setup attendee wiki.
# NOTE Apache site is managed by the 'my_bridgepdx_wordpress' recipe.

# Create directory
sitedir = "/var/www/bridgepdx_wiki"
mkdir_p(sitedir) and chperm(sitedir, :user => default_user, :group => default_group)

# Add task to dump database to file
cronedit(default_user) do
  append "18 * * * * if test -f #{sitedir}/LocalSettings.php; then (cd #{sitedir} && rake --silent dump); fi"

  # Delete previous cronjobs from back when there was a wiki per year
  delete %r{18 \* \* \* \* if test -f #{sitedir}_\d{4}/LocalSettings.php; then \(cd #{sitedir}_\d{4} \&\& rake --silent dump\); fi}
end

