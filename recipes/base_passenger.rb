# Setup Phusion Passenger

modified = false
modified |= package_manager.install "apache2-prefork-dev"
modified |= package_manager.install "passenger", :with => :gem, :docs => false

if modified
  sh "yes | passenger-install-apache2-module"
end

# Memory present, minus that needed for OS
memory_availabe = `free -m`.match(/Mem:\s+(\d+)/)[1].to_i - 128
pool_size = \
  case memory_availabe
  when 0 .. 128  then 4
  else                6
  end

# Retrieve information about installed package
version = `gem list passenger --local`[/ \((.+?)\)/, 1].split(', ').sort.last
passenger_path = File.dirname(`gem contents passenger --version #{version}`.split.first)
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

modified |= render :text => <<-HERE, :to => "/etc/apache2/mods-available/passenger.load"
LoadModule passenger_module #{passenger_path}/ext/apache2/mod_passenger.so
PassengerRoot               #{passenger_path}
PassengerRuby               #{ruby_path}
PassengerMaxPoolSize        #{pool_size}
PassengerMaxInstancesPerApp 2
HERE

if modified
  sh "a2enmod passenger"
  service_manager.tell :apache2, "force-reload"
end
