#!/bin/bash

#===[ Usage ]===========================================================

# This program helps those developing recipes. Running this program will
# display commands you can run on the virtual machine to sshfs mount the
# recipes and a version.

# The "local" host below refers to the computer you want to export data
# from (e.g., the project files). The "remote" host refers to the
# virtual machine you want to access these files from.

#===[ Settings ]========================================================

# Hostname or address to mount files from
host=${HOSTNAME}

# Local and remote directory with copies of downloaded APT packages:
apt_cache="/var/cache/apt/archives"

# Local directory with checkout of the project:
project_source="${PWD}"

# Remote directory to mount the project:
project_target="/var/local/automateit"

# Local directory with checkout of AutomateIt source code, which you
# probably don't want to do unless you're developing on it:
automateit_source="${PWD}/../automateit/app"

# Remote directory to mount AutomateIt source code:
automateit_target="/mnt/aisrc"

#===[ Output ]==========================================================

cat <<HERE
#===[ begin ]===========================================================
# Run the following commands on the remote virtual server:

# Mount project:
which sshfs || apt-get install -y sshfs
mkdir -p $project_target
fusermount -u -z $project_target
sshfs $host:$project_source $project_target
HERE

if [[ -d $automateit_source ]]; then
cat <<HERE

# Mount AutomateIt source:
mkdir -p $automateit_target
fusermount -u -z $automateit_target
sshfs $host:$automateit_source $automateit_target
export PATH=$automateit_target/bin:\$PATH
export RUBYLIB=$automateit_target/lib:\$RUBYLIB
HERE
fi

if [[ -d $apt_cache ]]; then
cat <<HERE

# Mount APT cache:
fusermount -u -z $apt_cache
sshfs -o nonempty $host:$apt_cache $apt_cache
cp -u -v $apt_cache/ruby-enterprise* /tmp
HERE
fi

echo "#===[ end ]============================================================="

#===[ fin ]=============================================================
