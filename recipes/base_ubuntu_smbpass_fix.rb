# Fix bug in Ubuntu regarding the smbpass PAM module. 
#
# The Ubuntu developers refuse to release a fix for this well-known problem
# which can be used as a denial of service attack and general annoyance. See:
# https://bugs.launchpad.net/ubuntu/+source/pam/+bug/216990
#
# The fix is to basically comment out some lines if a package isn't installed,
# and uncomment them if the package is installed.

files = [ '/etc/pam.d/common-password', '/etc/pam.d/common-auth' ]

command = package_manager.installed?('libpam-smbpass') ? 'uncomment' : 'comment'

for file in files
  edit file do
    send(command, /pam_smbpass.so/)
  end
end
