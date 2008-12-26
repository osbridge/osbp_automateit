# Setup build environment and common interpreters

package_manager.install <<-HERE
  # Compilers
  build-essential gcc autoconf libtool libreadline5-dev

  # Interpreters
  perl python expect tcl8.4
HERE
