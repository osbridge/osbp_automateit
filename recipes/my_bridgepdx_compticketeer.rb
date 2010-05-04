# Setup RedMine

sitename = "bridgepdx_compticketeer"
docroot = "/var/www/#{sitename}"
mkdir_p(docroot) && chown(default_user, default_group, docroot, :recursive => true)

modified = apache_manager.install_site(sitename)
apache_manager.reload if modified
