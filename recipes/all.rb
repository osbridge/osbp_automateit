# All recipes for this project

# Platform check
raise "Sorry, your platform is not supported" unless tagged?("ubuntu_8.04")

# Prepare
invoke 'base_airunners'
invoke 'base_apt'
invoke 'base_ruby'
invoke 'base_rubygems' # Relies on base_ruby
invoke 'base_gems' # Relies on base_ruby and base_rubygems
invoke 'base_ruby_github'
invoke 'base_locales'
invoke 'base_shmem'
invoke 'base_ubuntu_smbpass_fix'

# Base system
## Security and networking
invoke 'base_firewall'
invoke 'base_fail2ban'
invoke 'base_sudo'
invoke 'base_ssh'
invoke 'base_fuse'
invoke 'base_exim'
invoke 'base_cron_apt'
invoke 'base_ssl'
## Time and location
invoke 'base_timezone'
invoke 'base_ntpd'
## Monitoring
invoke 'base_logwatch' # Relies on base_exim
invoke 'base_sysstat'
invoke 'base_monit'
## Tools
invoke 'base_revision_control'
invoke 'base_compilers_and_interpreters'
invoke 'base_package_managers'
invoke 'base_python_easy_install'
invoke 'base_java'
invoke 'base_sqlite'

# Enable/disable penwrap proxy
invoke 'my_penwrap'

unless tagged?(:standby)
  # Base services
  invoke 'base_postgresql' # Relies on base_shmem
  invoke 'base_mysql'
  invoke 'base_apache'
  invoke 'base_php5'
  invoke 'base_ruby_enterprise'
  invoke 'base_passenger' # Relies on base_apache, base_ruby_enterprise
  invoke 'base_memcached'

  # Customizations
  invoke 'my_packages'
  invoke 'my_apache' # Relies on base_apache
  invoke 'my_ruby' # Relies on base_compilers_and_interpreters
  invoke 'my_bridgepdx_user'
  invoke 'my_bridgepdx_common' # Relies on my_apache, my_bridgepdx_user
  invoke 'my_bridgepdx_wordpress' # Relies on my_bridgepdx_common, my_apache, base_php5, base_mysql, my_bridgepdx_user
  invoke 'my_bridgepdx_wiki' # Relies on my_bridgepdx_wordpress, my_apache, base_php5, base_mysql
  invoke 'my_bridgepdx_ocw' # Relies on my_apache, my_ruby, my_bridgepdx_user
  invoke 'my_bridgepdx_secrets' # Relies on my_apache, base_php5, my_bridgepdx_user
  invoke 'my_bridgepdx_stats' # Relies on my_apache, base_php5, my_bridgepdx_user
  invoke 'my_reown'
end
