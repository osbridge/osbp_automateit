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
sitename = "bridgepdx_ocw"
docroot = "/var/www/#{sitename}"

# Setup directory
mkdir_p(docroot) && chown(default_user, default_group, docroot, :recursive => true)

# Setup apache
modified = apache_manager.install_site(sitename)

# Reload apache if needed
apache_manager.reload if modified

# Add task to dump database to file
cronedit(default_user) do
  append "# m h  dom mon dow   command"
  append "19 * * * * if test -f /var/www/bridgepdx_ocw/current/Rakefile; then (cd /var/www/bridgepdx_ocw/current && rake RAILS_ENV=production --silent db:raw:dump FILE=/var/www/bridgepdx_ocw/shared/db/production.sql); fi"
end
