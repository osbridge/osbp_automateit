# Install Ruby, RubyGems and AutomateIt
apt-get update
apt-get install -y ruby1.8 ruby1.8-dev irb1.8 ri1.8 rdoc1.8 \
    libopenssl-ruby1.8 libxml-ruby
ln -s /usr/bin/ruby1.8 /usr/bin/ruby
pushd /tmp
wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz
tar xvfz rubygems-1.3.1.tgz
cd rubygems-1.3.1
ruby setup.rb
popd
ln -s /usr/bin/gem1.8 /usr/bin/gem
gem install automateit --no-ri --no-rdoc

