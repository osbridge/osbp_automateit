# Setup ntpd for keeping time in sync

# Do not use NTP on OpenVZ VMs, it can't set the clock.
if !File.exist?('/proc/vz/veinfo') || File.read('/proc/vz/veinfo').strip.empty?
  modified = package_manager.install %w[ntpdate ntp]

  # Sync the time
  sh "/etc/network/if-up.d/ntpdate" if modified

  service_manager.enable "ntp"
  service_manager.start "ntp"
end
