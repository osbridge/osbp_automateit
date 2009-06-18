# Setup 'locate' command and populate its index.

package_manager.install("locate", "mlocate")

mlocate_cron = "/etc/cron.daily/mlocate"
if cpdist(mlocate_cron)
  sh mlocate_cron
end
