# All recipes for this project

# Platform check
raise "Sorry, your platform is not supported" unless tagged?("ubuntu_8.04")

# Prepare
invoke 'base_apt'
invoke 'base_ruby'
invoke 'base_rubygems' # Relies on base_ruby
invoke 'base_gems' # Relies on base_ruby and base_rubygems
invoke 'base_ruby_github'
invoke 'base_locales'

# Base system
## Security
invoke 'base_firewall'
invoke 'base_fail2ban'
invoke 'base_ssh_gateway'
invoke 'base_fuse'
invoke 'base_exim'
invoke 'base_logwatch' # Relies on base_exim
invoke 'base_sysstat'
## Time and location
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
invoke 'base_postgresql' # Relies on base_shmem
invoke 'base_mysql'
invoke 'base_monit'
invoke 'base_apache'
invoke 'base_php5'
invoke 'base_ruby_enterprise'
invoke 'base_passenger' # Relies on base_apache, base_ruby_enterprise
invoke 'base_memcached'

# Customizations
invoke 'my_packages'
invoke 'my_apache'
invoke 'my_ruby' # Relies on base_compilers_and_interpreters
invoke 'my_reown'
invoke 'my_bridgepdx_user'
invoke 'my_bridgepdx_wordpress' # Relies on base_apache, my_apache, base_php5, base_mysql
