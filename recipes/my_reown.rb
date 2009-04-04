# Setup "reown" program to chown/chmod group owned files

package_manager.install "acl"

reown = "/usr/local/bin/reown"

modified = cp dist+reown, reown, :user => "root", :group => "root", :mode => 0755

edit "/etc/sudoers" do
  append "%bridgepdx ALL = NOPASSWD: #{reown}"
end

edit("/var/spool/cron/crontabs/root", :create => true, :user => "root", :group => "crontab", :mode => 0600, :params => {:reown => reown}) do
  append "# m h  dom mon dow   command"
  delete /#{params[:reown]}/
end

sh(reown) if modified
