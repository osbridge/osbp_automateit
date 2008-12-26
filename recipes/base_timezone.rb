# Set system timezone
#
# NOTE: Set the "timezone" field to override default.

timezone = lookup(:timezone) rescue "America/Los_Angeles"

cp "/usr/share/zoneinfo/"+timezone, "/etc/localtime"
edit "/etc/timezone", :params => {:timezone => timezone} do
  delete /.*/
  prepend params[:timezone]
end
