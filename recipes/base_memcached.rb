# Setup memcached, a memory-based caching daemon
#
# NOTE: Relies on "lib/pgrep.rb"

package_manager.install <<-HERE
  libmemcache-dev
  memcached
HERE

service = "memcached"
service_manager.enable(service)
service_manager.start(service) unless pgrep?(service)
