# Setup apt

# Specify list of apt repositories to use
if cpdist("/etc/apt/sources.list")
  # Use the new apt repositories if the list was updated
  sh "apt-get update && apt-get dist-upgrade"
end
