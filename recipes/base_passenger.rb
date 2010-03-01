# Setup Phusion Passenger
#
# NOTE: The Passenger configuration variables for "pool_size" and
# "max_instances" can be calculated automatically or overriden by setting
# specific values in "fields.yml", e.g.:
#
#     passenger:
#        pool_size: 8
#        max_instances: 6

#---[ Settings ]--------------------------------------------------------

# What version of Passenger to use:
passenger_version = Gem::Version.new('2.2.9')

# Ruby to use in order of preference:
ruby_basedirs = ["/opt/ruby-enterprise", "/usr/local", "/usr/bin"].select{|t| File.exist?(t)}
ruby_interpreters = ruby_basedirs.map{|base| "#{base}/bin/ruby"}.select{|t| File.exist?(t)}
ruby_interpreter = ruby_interpreters.first

#---[ Logic ]-----------------------------------------------------------

passenger_needs_installing = false

if package_manager.installed?("passenger", :with => :gem)
  # What versions of Passenger are installed?
  versions = `gem list passenger --local`[/ \((.+?)\)/, 1].split(', ').map{|string| Gem::Version.new(string)}.sort

  # Uninstall with all versions of gem since there are multiple ones :(
  unless versions.last == passenger_version
    for ruby_basedir in ruby_basedirs
      sh "#{ruby_basedir}/bin/gem uninstall passenger -x -a > /dev/null 2>&1"
    end
    modified = true
    passenger_needs_installing = true
  end
else
  passenger_needs_installing = true
end

# Install Passenger if needed
if passenger_needs_installing
  # TODO package_manager.install("passenger", :with => :gem, :version => passenger_version.to_s)
  sh "gem install passenger --no-ri --no-rdoc --version #{passenger_version}"
end

# Determine what path Ruby is installed in
gem_needs_prefix = `gem contents --help`.match(/--prefix/m)
passenger_path = File.dirname(`gem contents passenger --version #{passenger_version} #{gem_needs_prefix ? '--prefix' : ''}`.split.first)

# Compile Passenger if needed
passenger_so = "#{passenger_path}/ext/apache2/mod_passenger.so"
if modified || ! File.exist?(passenger_so)
  sh "yes | passenger-install-apache2-module"
end

# Calculate the number of Passenger instances to use if one hasn't been set
pool_size = lookup('passenger#pool_size') rescue nil
max_instances = lookup('passenger#max_instances') rescue nil
unless pool_size
  memory_capacity = `free -m`.match(/Mem:\s+(\d+)/)[1].to_i
  pool_size = \
    case memory_capacity
    when 0 .. 256 then 2
    else ((memory_capacity-128)/100.0).ceil
    end
end

# Generate the configuration file to load Passenger into Apache
modified |= render :text => <<-HERE, :to => "/etc/apache2/mods-available/passenger.load"
LoadModule passenger_module #{passenger_so}
PassengerRoot               #{passenger_path}
PassengerRuby               #{ruby_interpreter}
PassengerMaxPoolSize        #{pool_size}
#{max_instances ? 'PassengerMaxInstancesPerApp %i' % max_instances : ''}
HERE

# Enable Passenger and restart Apache if needed
modified |= apache_manager.enable_module "passenger"
apache_manager.reload if modified
