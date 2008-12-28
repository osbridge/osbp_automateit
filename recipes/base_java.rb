# Setup Java

java_package = "sun-java6-jdk"

=begin
# Find out which configuration fields are used by Java:
% debconf-get-selections | grep java
sun-java6-bin   shared/accepted-sun-dlj-v1-1    boolean false
sun-java6-jdk   shared/accepted-sun-dlj-v1-1    boolean false
sun-java6-jre   shared/accepted-sun-dlj-v1-1    boolean false
...
=end

java_licence_accepted = lambda do
  !`debconf-get-selections | grep #{java_package}`.match(/#{java_package}.+accepted.+true/s).nil?
end

unless package_manager.installed?(java_package)
  unless java_licence_accepted.call
    sh "echo '#{java_package}   shared/accepted-sun-dlj-v1-1    boolean true' | debconf-set-selections"
    unless preview?
      java_licence_accepted.call or raise "Couldn't accept Java license"
    end
  end
  package_manager.install(java_package)
end
