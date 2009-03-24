# Setup directory for common images and styles for OpenSourceBridge

mkdir_p("/var/www/bridgepdx_common") && chown("bridgepdx", "bridgepdx", "/var/www/bridgepdx_common", :recursive => true)
#IK# system("/usr/local/bin/reown -q &") unless preview?
