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

# Install PHP OpenID library, downloaded from http://openidenabled.com/php-openid/
### FIXME AutomateIt is getting confused because it sees two "//"s and thus isn't matching
# path = "/usr/share/php/Auth"; cp(dist+path, path)
### Workaround:
path = "usr/share/php/Auth"; cp(dist+path, "/"+path)
