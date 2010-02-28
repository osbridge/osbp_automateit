# Prepare your development virtual machine

# WARNING! DO NOT RUN THESE COMMANDS ON PRODUCTION SERVERS! These
# instructions are only intended for use on development virtual
# machines.

# WARNING! DO NOT RUN THESE COMMANDS AS-IS! Your computer will have
# different paths and you will want to make a copy of this file, update
# its CONFIGURATION DIRs, and use this personalized copy. Do not make
# changes to this "devprep.sh" file itself.

# CONFIGURATION
## Directory for storing downloaded APT packages
APT_CACHE_DIR=murad:/var/cache/apt/archives
## Directory with checkout of the OSBP AutomateIt project
PROJECT_CHECKOUT_DIR=murad:/home/igal/workspace/osbp_automateit
## Directory with checkout of the AutomateIt source code
AUTOMATEIT_CHECKOUT_DIR=murad:/home/igal/workspace/automateit/app

apt-get install -y sshfs
mkdir -p /var/local/automateit
mkdir -p /mnt/aisrc
fusermount -u -z /var/cache/apt/archives
fusermount -u -z /mnt/aisrc
fusermount -u -z /var/local/automateit
sshfs -o nonempty $APT_CACHE_DIR /var/cache/apt/archives
sshfs $PROJECT_CHECKOUT_DIR /var/local/automateit
sshfs $AUTOMATEIT_CHECKOUT_DIR /mnt/aisrc
export PATH=/mnt/aisrc/bin:$PATH
export RUBYLIB=/mnt/aisrc/lib:$RUBYLIB
rsync -uvax /var/cache/apt/archives/ruby-enterprise* /tmp
