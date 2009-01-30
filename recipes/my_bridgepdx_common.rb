# Setup directory for common images and styles for OpenSourceBridge

mkdir_p("/var/www/bridgepdx_common")
system("/usr/local/bin/reown -q") unless preview?
