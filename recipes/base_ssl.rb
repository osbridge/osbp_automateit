# Setup SSL related packages.

package_manager.install <<-HERE
  ca-certificates
  libssl0.9.8
  libssl-dev
  openssl
  openssl-blacklist-extra
  openssl-blacklist
  libcurl4-openssl-dev
HERE
