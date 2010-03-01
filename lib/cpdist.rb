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
  # TODO improve #cp to do this on its own
  return cp(File.expand_path(dist+filename), File.expand_path(filename), *args)
end
