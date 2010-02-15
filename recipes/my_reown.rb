# Setup "reown" program to chown/chmod group owned files

package_manager.install "acl"

reown = "/usr/local/bin/reown"

modified = cp dist+reown, reown, :user => "root", :group => "root", :mode => 0755

edit "/etc/sudoers" do
  append "%#{default_user} ALL = NOPASSWD: #{reown}"
end

cronedit("root") do
  append "# m h  dom mon dow   command"
  delete /#{reown}/
end

sh(reown) if modified
