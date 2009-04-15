# Setup OpenConferenceWare

# Gems
package_manager.install <<-HERE, :with => :gem, :docs => false
  mbleigh-acts-as-taggable-on
  right_aws
  thoughtbot-paperclip
  ruby-openid
  RedCloth
HERE

# Libraries
package_manager.install <<-HERE
  imagemagick
HERE

# Variables
user = "bridgepdx"
sitename = "bridgepdx_ocw"
docroot = "/var/www/#{sitename}"

# Setup directory
mkdir_p(docroot) && chown(user, user, docroot, :recursive => true)

# Setup apache
modified = apache_manager.install_site(sitename)

# Reload apache if needed
apache_manager.reload if modified
