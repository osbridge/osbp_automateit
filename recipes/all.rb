# All recipes for this project

# Bootstrap
invoke 'base_ruby'
invoke 'base_rubygems' # Relies on base_ruby
invoke 'base_gems' # Relies on base_ruby and base_rubygems

# Base system
## Security
invoke 'base_firewall'
invoke 'base_fail2ban'
invoke 'base_ssh_gateway'
invoke 'base_logwatch'
invoke 'base_sysstat'
## Time and location
invoke 'base_locales'
invoke 'base_timezone'
invoke 'base_ntpd'
## Tools
invoke 'base_revision_control'
invoke 'base_compilers_and_interpreters'
invoke 'base_package_managers'
invoke 'base_python_easy_install'
invoke 'base_java'

# Base services
invoke 'base_shmem'
invoke 'base_exim'
invoke 'base_fuse'
invoke 'base_monit'
invoke 'base_apache'
invoke 'base_ruby_enterprise'
invoke 'base_passenger' # Relies on base_apache
invoke 'base_postgresql' # Relies on base_shmem

# Customizations
invoke 'my_packages'
invoke 'my_ruby'
