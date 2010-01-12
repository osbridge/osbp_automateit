# Setup a wiki for storing secrets.

certificate = "/etc/ssl/certs/bridgepdx_secrets.pem"
if File.exist?(certificate)
  user = "bridgepdx"
  sitename = "bridgepdx_secrets"
  docroot = "/var/www/#{sitename}"
  mkdir_p(docroot) && chown(user, user, docroot, :recursive => true)

  apache_manager.enable_module "ssl"
  modified = apache_manager.install_site(sitename)
  apache_manager.reload if modified
else
  puts <<EOB
WARNING: Skipped "my_bridgepdx_secrets" recipe, couldn't find its SSL certificate. Restore the certificate from backups to "#{certificate}" or create a new one by running: make-ssl-cert /usr/share/ssl-cert/ssleay.cnf #{certificate} 
EOB
end
