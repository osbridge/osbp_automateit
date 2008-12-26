# Make the OS stop whining about missing locales

modified = package_manager.install <<-HERE
  locales language-pack-en
HERE

if modified
  sh "locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8"
end
