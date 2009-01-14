# Setup 'reown' program to chown/chmod group owned files

path = "/usr/local/bin/reown"

cp dist+path, path, :user => "root", :group => "root", :mode => 0755

edit '/etc/sudoers' do
  append '%bridgepdx ALL = NOPASSWD: /usr/local/bin/reown'
end
