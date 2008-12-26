# Setup Phusion Ruby Enterprise Edition
#
# NOTE: This depends on the "base_stow" recipe.

#---[ Setup ]-----------------------------------------------------------

# URL from distro site at http://www.rubyenterpriseedition.com/download.html
url = "http://rubyforge.org/frs/download.php/48623/ruby-enterprise-1.8.6-20081215.tar.gz"

#---[ Install ]---------------------------------------------------------

prefix  = "ruby-enterprise"
archive = File.basename(url)
package = File.basename(archive, ".tar.gz")
stowage = File.join(stow_dir, package)

unless File.directory?(stowage)
  package_manager.install <<-HERE
    zlib1g-dev
    libssl-dev
    libsqlite3-dev
  HERE

  archive_fqfn = File.join("/tmp", archive)
  unless File.exists?(archive_fqfn)
    # TODO Make AutomateIt's DownloadManager only download when needed
    download url, archive_fqfn
  end

  mktempdircd do
    sh "tar xvfz #{archive_fqfn}"
    cd package do
      sh "./installer --auto #{stowage}"
    end
  end

  cd stow_dir do
    sh "stow --delete #{prefix}-*"
    sh "stow #{package}"
  end
end

# Use existing gems
edit "/usr/local/lib/ruby/site_ruby/1.8/rubygems.rb" do
  manipulate do |buffer|
    unless contains? /GEM_PATH hacked/
      buffer.gsub!(
        %r{(require 'rubygems/rubygems_version')},
        %{# GEM_PATH hacked\nENV['GEM_PATH'] ||= '/usr/lib/ruby/gems/1.8'\n\n\\1})
    end
    buffer
  end
end
