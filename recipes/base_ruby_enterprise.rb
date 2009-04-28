# Setup Ruby Enterprise Edition

if tagged?('i386 | i486 | i586 | i686')
  invoke 'base_ruby_enterprise_from_package'
else
  invoke 'base_ruby_enterprise_from_source'
end

