# Setup Phusion Passenger
#
# NOTE: The Passenger pool_size and max_instances are automatically set.
# However, you can set specific values in the fields.yml, e.g.:
#   passenger:
#     pool_size: 8
#     max_instances: 6

modified = false
modified |= package_manager.install "apache2-prefork-dev"
modified |= package_manager.install "passenger", :with => :gem, :docs => false

# Memory present, minus that needed for OS
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

# Retrieve information about installed package
version = `gem list passenger --local`[/ \((.+?)\)/, 1].split(', ').sort.last
gem_needs_prefix = `gem contents --help`.match(/--prefix/m)
passenger_path = File.dirname(`gem contents passenger --version #{version} #{gem_needs_prefix ? '--prefix' : ''}`.split.first)
ruby_path = nil
ruby_paths = ["/opt/ruby-enterprise", "/usr/local", "/usr/bin"]
ruby_paths.each do |prefix|
  a_ruby_path = File.join(prefix, "bin", "ruby")
  if File.exist?(a_ruby_path)
    ruby_path = a_ruby_path
    break
  end
end
raise "Can't find Ruby's path" unless ruby_path

passenger_so = "#{passenger_path}/ext/apache2/mod_passenger.so"
if modified || ! File.exist?(passenger_so)
  sh "yes | passenger-install-apache2-module"
end

modified |= render :text => <<-HERE, :to => "/etc/apache2/mods-available/passenger.load"
LoadModule passenger_module #{passenger_so}
PassengerRoot               #{passenger_path}
PassengerRuby               #{ruby_path}
PassengerMaxPoolSize        #{pool_size}
#{max_instances ? 'PassengerMaxInstancesPerApp %i' % max_instances : ''}
HERE

modified |= apache_manager.enable_module "passenger"
apache_manager.reload if modified
