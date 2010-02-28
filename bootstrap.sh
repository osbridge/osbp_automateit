### Install Ruby, RubyGems, AutomateIt, and then checkout project

# Get the latest packages
apt-get update
apt-get dist-upgrade

# Install ruby
apt-get install -y ruby1.8 ruby1.8-dev irb1.8 ri1.8 rdoc1.8 \
    libopenssl-ruby1.8 libxml-ruby wget
ln -s /usr/bin/ruby1.8 /usr/bin/ruby

# Install gem
pushd /tmp
    wget -c http://rubyforge.org/frs/download.php/69365/rubygems-1.3.6.tgz
    tar xvfz rubygems-1.3.6.tgz
    cd rubygems-1.3.6
    ruby setup.rb
popd
ln -s /usr/bin/gem1.8 /usr/bin/gem

# Install automateit
gem install automateit --no-ri --no-rdoc

# Checkout project
apt-get install stow git-core -y
mkdir -p /var/local
git clone git://github.com/igal/osbp_automateit.git /var/local/automateit

# TODO Manually install the /var/local/automateit/config/secrets.yml

# Apply recipes
cd /var/local/automateit
rake
