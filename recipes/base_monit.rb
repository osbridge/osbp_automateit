# Setup the Monit health monitor
#
# NOTE: You must create a "dist/etc/monit/monitrc" file to install Monit. A
# sample is available as "dist/etc/monit/monitrc.sample"
#
# NOTE: Relies on "lib/pgrep.rb"

target_monitrc = "/etc/monit/monitrc"
source_monitrc = dist+target_monitrc

raise "Couldn't find #{source_monitrc}, for sample see #{source_monitrc}.sample" unless File.exist?(source_monitrc)

modified = package_manager.install 'monit'

# Install configuration file
modified |= cp source_monitrc, target_monitrc, :mode => 0444

# Install init file, because default doesn't check syntax
modified |= cpdist("/etc/init.d/monit", :mode => 0555)

# Enable startup
modified |= \
  edit :file => "/etc/default/monit" do
    replace /^startup=0/, "startup=1"
  end

# Run service
if modified
  if pgrep?(:monit)
    service_manager.tell :monit, "force-reload"
  else
    service_manager.start :monit
  end
end
