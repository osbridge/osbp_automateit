# Setup SysV shared memory

modified = edit "/etc/sysctl.conf" do
  delete /kernel.shmall/
  append "kernel.shmall = 134217728" # 128 MB

  delete /kernel.shmmax/
  append "kernel.shmmax = 134217728" # 128 MB
end

sh "sysctl -p" if modified
