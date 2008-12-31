# Setup the fail2ban tool to prevent brute-force attacks on ssh

package_manager.install <<-HERE
  fail2ban
  python-gamin
  iptables
HERE
