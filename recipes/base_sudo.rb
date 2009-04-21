# Setup sudo

package_manager.install "sudo"

edit "/etc/sudoers" do
  comment /%sudo\s+ALL\s*=\s*NOPASSWD:\s*ALL/
  append "%sudo ALL = (ALL) ALL"
end
