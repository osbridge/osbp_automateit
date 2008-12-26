# Setup ntpd for keeping time in sync

modified = package_manager.install %w[ntpdate ntp]

# Sync the time
sh "/etc/network/if-up.d/ntpdate" if modified

service_manager.enable "ntp"
service_manager.start "ntp"
