# Setup firewall
#
# NOTE: Add your custom rules to "dist/etc/firewall_rules.sh"

initializer = "/etc/init.d/firewall"
rules       = "/etc/firewall_rules.sh"

package_manager.install "iptables"

modified = false
modified |= cpdist(initializer, :mode => 0555, :user => "root", :group => "root")
modified |= cpdist(rules,       :mode => 0555, :user => "root", :group => "root")

service_manager.restart("firewall") if modified
service_manager.enable("firewall")
