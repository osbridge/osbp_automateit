# Setup apt

filename = "/etc/apt/sources.list"
cp dist+filename, filename
sh "apt-get update"