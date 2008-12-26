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

# Retrieve version of installed package
# TODO Gem API can't find package here, yet finds it from IRB. Why?
#IK# version = Gem.source_index.search('passenger').map{|spec| spec.version}.sort.last.to_s
version = `gem list passenger --local`[/ \((.+?)\)/, 1].split(', ').sort.last

modified |= render :text => <<-HERE, :to => "/etc/apache2/mods-available/passenger.load"
LoadModule passenger_module /usr/local/lib/ruby/gems/1.8/gems/passenger-#{version}/ext/apache2/mod_passenger.so
PassengerRoot               /usr/local/lib/ruby/gems/1.8/gems/passenger-#{version}
PassengerRuby               /usr/local/bin/ruby
PassengerMaxPoolSize        #{pool_size}
PassengerMaxInstancesPerApp 2
HERE

if modified
  sh "a2enmod passenger"
  service_manager.tell :apache2, "force-reload"
end
