# Prepare for MediaWiki
# NOTE Depends on: base_php, base_apache, base_compilers_and_interpreters

# Install dependencies
package_manager.install <<-HERE
  php5-gmp
  php5-curl
HERE

# Install PHP OpenID library, downloaded from http://openidenabled.com/php-openid/
cpdist "/usr/share/php/Auth"
