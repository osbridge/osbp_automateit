# Install SSH
package_manager.install 'ssh'

# Setup SSH with gateway ports to allow reverse proxying
edit "/etc/ssh/sshd_config" do
  append "GatewayPorts yes" # Allow user to reverse proxy tunnel
end