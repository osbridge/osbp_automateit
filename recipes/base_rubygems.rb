# Setup RubyGem

# Version and URL can be found at main downloads site: http://rubyforge.org/frs/?group_id=126
version = "1.3.1"
url = "http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz"
archive = File.basename(url)
directory = File.basename(archive, File.extname(url))

#-----------------------------------------------------------------------

needs_installing = which("gem") ? version > `gem -v`.strip : true

if needs_installing
  mktempdircd do
    download url
    sh "tar xvfz #{archive}"
    cd directory do
      sh "ruby setup.rb"
    end
  end
end

ln_sf("/usr/bin/gem1.8", "/usr/bin/gem")
