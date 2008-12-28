# Setup SysV shared memory
#
# NOTE: Can use "shmem#shmall" and "shmem#shmmax" fields to define values

modified = edit "/etc/sysctl.conf" do
  delete /kernel.shmall/
  append "kernel.shmall = #{lookup 'shmem#shmall' rescue 134217728}"

  delete /kernel.shmmax/
  append "kernel.shmmax = #{lookup 'shmem#shmmax' rescue 134217728}"
end

sh "sysctl -p" if modified
