# Setup Ruby

package_manager.install <<-HERE
  irb1.8
  ri1.8
  rdoc1.8
  libxml-ruby
HERE

ln_sf '/usr/bin/irb1.8',  '/usr/bin/irb'
ln_sf '/usr/bin/ri1.8',   '/usr/bin/ri'
ln_sf '/usr/bin/rdoc1.8', '/usr/bin/rdoc'
