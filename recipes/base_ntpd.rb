# Setup ntpd for keeping time in sync

# Do not use NTP on an OpenVZ container, it can't set the clock.
unless tagged?(:openvz_container)
  modified = package_manager.install %w[ntpdate ntp]

  # Sync the time
  sh "/etc/network/if-up.d/ntpdate" if modified

  service_manager.enable "ntp"
  service_manager.start "ntp"
end
