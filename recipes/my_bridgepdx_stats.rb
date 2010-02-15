# Setup attendee wiki.
# NOTE Apache site is managed by the 'my_bridgepdx_wordpress' recipe.

# Install dependencies
package_manager.install <<-HERE
  php5-gd
HERE

# Create directory
path = "/var/www/bridgepdx_stats"
mkdir_p(path) and chperm(path, :user => default_user, :group => default_group)
