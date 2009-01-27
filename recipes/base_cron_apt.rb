# Setup cron-apt, it regularly updates the apt database, downloads new
# packages, and notifies by email that updates are available
#
# Log: /var/log/cron-apt/log

package_manager.install 'cron-apt'
edit '/etc/cron-apt/config' do
  comment %r{^MAILTO="(?!root)"}
  append     'MAILTO="root"'
  uncomment  'MAILTO="root"'

  comment %r{^MAILON="(?!upgrade)"}
  append     'MAILON="upgrade"'
  uncomment  'MAILON="upgrade"'
end
ln_s '/usr/sbin/cron-apt', '/etc/cron.daily/cron-apt'
