# Is there a process running with this +name+? Must have +pgrep+ UNIX utility
# installed.
def pgrep?(name)
  name = name.to_s
  return system("pgrep #{name} > /dev/null")
end
