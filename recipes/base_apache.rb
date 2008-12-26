# Setup Apache web server

modified = package_manager.install %w[apache2]

service_manager.enable "apache2"
service_manager.tell "apache2", "restart" if modified
