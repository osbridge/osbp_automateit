# Setup Phusion Ruby Enterprise Edition

# URL from distro site at http://www.rubyenterpriseedition.com/download.html
url = \
  if tagged?('x86_64')
    "http://rubyforge.org/frs/download.php/68720/ruby-enterprise_1.8.7-2010.01_amd64.deb"
  elsif tagged?('i386 | i486 | i586 | i686')
    "http://rubyforge.org/frs/download.php/68718/ruby-enterprise_1.8.7-2010.01_i386.deb"
  else
    raise NotImplementedError, "Unknown architecture"
  end

# Extract version from URL above, e.g., "1.8.7-2010.01"
desired_version = url.split('/').last.gsub(/^.+?_/, '').gsub(/_[^_]+\.deb$/, '')
current_version = `apt-cache show ruby-enterprise 2>&1`[/Version: ([\.\d+-]+)/m, 1]

# Download and install/upgrade if needed
package = File.basename(url)
package_dir = "/tmp"
package_fqfn = File.join(package_dir, package)
if desired_version != current_version
  cd package_dir do
    download url unless File.exists?(package)
    # TODO add package_manager :force? or versioning logic?
    #IK# package_manager.install({"ruby-enterprise" => package_fqfn}, :with => :dpkg)
    sh "export DEBIAN_FRONTEND=noninteractive; dpkg --install --skip-same-version #{package_fqfn} < /dev/null 2>&1"
  end
end

invoke 'base_ruby_enterprise_fix_gem_path'
