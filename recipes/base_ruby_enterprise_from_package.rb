# Setup Phusion Ruby Enterprise Edition

# URL from distro site at http://www.rubyenterpriseedition.com/download.html
url = \
  if tagged?('x86_64')
    "http://www.rubyenterpriseedition.com/ruby-enterprise_1.8.6-20090610_amd64.deb"
  elsif tagged?('i386 | i486 | i586 | i686')
    "http://www.rubyenterpriseedition.com/ruby-enterprise_1.8.6-20090610_i386.deb"
  else
    raise NotImplementedError, "Unknown architecture"
  end

package = File.basename(url)
package_dir = "/tmp"
package_fqfn = File.join(package_dir, package)
unless package_manager.installed?("ruby-enterprise")
  cd package_dir do
    download url unless File.exists?(package)
    package_manager.install({"ruby-enterprise" => package_fqfn}, :with => :dpkg)
  end
end

# Use existing gems
edit "/opt/ruby-enterprise/lib/ruby/site_ruby/1.8/rubygems.rb" do
  manipulate do |buffer|
    unless contains? /GEM_PATH hacked/
      buffer.gsub!(
        %r{(require 'rubygems/rubygems_version')},
        %{# GEM_PATH hacked\nENV['GEM_PATH'] ||= '/usr/lib/ruby/gems/1.8'\n\n\\1})
    end
    buffer
  end
end
