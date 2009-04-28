# Setup Phusion Ruby Enterprise Edition

# URL from distro site at http://www.rubyenterpriseedition.com/download.html
url = "http://rubyforge.org/frs/download.php/48625/ruby-enterprise_1.8.6-20081215-i386.deb"

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
