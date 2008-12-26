# All recipes for this project

# Bootstrap
invoke 'base_ruby'
invoke 'base_rubygems'
invoke 'base_gems'

# Base system
invoke 'base_compilers_and_interpreters'
invoke 'base_package_managers'
invoke 'base_locales'
invoke 'base_timezone'
invoke 'base_ntpd'
invoke 'base_logwatch'
invoke 'base_fail2ban'
invoke 'base_ssh_gateway'
invoke 'base_exim'
invoke 'base_python_easy_install'
invoke 'base_revision_control'

# Base services
invoke 'base_fuse'
invoke 'base_monit'
invoke 'base_apache'
invoke 'base_ruby_enterprise'
invoke 'base_passenger'

# Customizations
invoke 'my_packages'
invoke 'my_ruby'
