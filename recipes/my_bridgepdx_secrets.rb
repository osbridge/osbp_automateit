# Setup a wiki for storing secrets.

# You'll need to create an SSL certificate with a command like:
### make-ssl-cert /usr/share/ssl-cert/ssleay.cnf /etc/ssl/certs/bridgepdx_secrets.pem

user = "bridgepdx"
sitename = "bridgepdx_secrets"
docroot = "/var/www/#{sitename}"
mkdir_p(docroot) && chown(user, user, docroot, :recursive => true)

apache_manager.enable_module "ssl"
modified = apache_manager.install_site(sitename)
apache_manager.reload if modified
