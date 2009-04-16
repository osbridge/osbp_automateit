# Setup attendee wiki.
# NOTE Apache site is managed by the 'my_bridgepdx_wordpress' recipe.

# Install dependencies
package_manager.install <<-HERE
  php5-gmp
  php5-curl
HERE

# Create directory
path = "/var/www/bridgepdx_wiki"
mkdir_p(path) and chperm(path, :user => "bridgepdx", :group => "bridgepdx")
