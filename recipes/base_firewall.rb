# Setup firewall
#
# NOTE: Add your custom rules to "dist/etc/firewall_rules.sh"

initializer = "/etc/init.d/firewall"
rules       = "/etc/firewall_rules.sh"

package_manager.install "iptables"

modified = false
modified |= cp(dist+initializer, initializer, :mode => 0555, :user => "root", :group => "root")
modified |= cp(dist+rules,       rules,       :mode => 0555, :user => "root", :group => "root")

service_manager.restart("firewall") if modified
service_manager.enable("firewall")
