# TODO Incorporate this into AutomateIt?
#
# Copy a file from dist to local filesystem.
#
# Example:
#   # Native syntax:
#   filename = "/foo"
#   cp(dist+filename, filename)
#
#   # Same thing with cpdist:
#   cpdist(filename)
def cpdist(filename, *args)
  return cp(dist+filename, filename, *args)
end
