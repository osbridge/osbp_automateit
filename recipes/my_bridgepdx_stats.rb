# Setup attendee wiki.
# NOTE Apache site is managed by the 'my_bridgepdx_wordpress' recipe.

user = "bridgepdx"

# Install dependencies
package_manager.install <<-HERE
  php5-gd
HERE

# Create directory
path = "/var/www/bridgepdx_stats"
mkdir_p(path) and chperm(path, :user => "bridgepdx", :group => "bridgepdx")
