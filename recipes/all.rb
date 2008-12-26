# All recipes for this project

# Bootstrap
invoke 'base_ruby'
invoke 'base_rubygems'
invoke 'base_gems'

# Base system
invoke 'base_stow'
invoke 'base_locales'
invoke 'base_timezone'
invoke 'base_ntpd'
invoke 'base_logwatch'
invoke 'base_fail2ban'
invoke 'base_ssh_gateway'
invoke 'base_exim'
invoke 'base_python_easy_install'

# Base services
#TODO invoke 'base_monit'
#TODO invoke 'base_apache'
#TODO invoke 'base_ruby_enterprise'
#TODO invoke 'base_passenger'

# Customizations
#TODO invoke 'my_packages'
#TODO invoke 'my_ruby'
