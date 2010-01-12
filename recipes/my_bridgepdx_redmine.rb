# Setup RedMine

user = "bridgepdx"
sitename = "bridgepdx_redmine"
docroot = "/var/www/#{sitename}"
mkdir_p(docroot) && chown(user, user, docroot, :recursive => true)

modified = apache_manager.install_site(sitename)
apache_manager.reload if modified
