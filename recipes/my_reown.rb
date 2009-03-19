# Setup 'reown' program to chown/chmod group owned files

path = "/usr/local/bin/reown"

cp dist+path, path, :user => "root", :group => "root", :mode => 0755

edit '/etc/sudoers' do
  append '%bridgepdx ALL = NOPASSWD: /usr/local/bin/reown'
end

edit('/var/spool/cron/crontabs/root', :create => true, :user => 'root', :group => 'crontab', :mode => 0600) do
  append '# m h  dom mon dow   command'
  delete '* * * * * /usr/local/bin/reown --quiet'
  append '*/5 * * * * /usr/local/bin/reown --quiet'
end
