# Setup directory for common images and styles for OpenSourceBridge

mkdir_p("/var/www/bridgepdx_common") && chown(default_user, default_group, "/var/www/bridgepdx_common", :recursive => true)
