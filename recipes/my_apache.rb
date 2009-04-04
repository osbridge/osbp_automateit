# Setup additional Apache features

modified = false

# Apache modules to enable
modified |= apache_manager.enable_modules %w[
  vhost_alias
  rewrite
  deflate
  headers
  expires
  proxy
  proxy_http
]

# Setup default site, no need to enable because it's already enabled as 000-default
modified |= apache_manager.install_site "default", :enable => false

# Reload apache if needed
apache_manager.reload if modified
