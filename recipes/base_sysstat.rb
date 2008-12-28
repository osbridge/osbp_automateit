# Setup system status recorder

package_manager.install "sysstat", "acct"

edit "/etc/default/sysstat" do
  replace 'ENABLED="false"', 'ENABLED="true"'
end

edit "/etc/default/acct" do
  replace 'ENABLED="0"', 'ENABLED="1"'
end

# No need to enable/start because sysstat is run out of cron.
