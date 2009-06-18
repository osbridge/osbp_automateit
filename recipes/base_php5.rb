# Setup PHP5.
#
# This recipe will also modify the PHP5 settings for:
# - Maximum amount of memory based on the "php5#memory_limit" field, else use
#   the default value below.
# - Maximum size of file uploads based on the "php5#upload_max_filesize"
#   field, else use the default value below.

memory_limit = lookup("php5#memory_limit") rescue "64M"
upload_max_filesize = lookup("php5#upload_max_filesize") rescue "8M"

package_manager.install <<-HERE
  apache2
  libapache2-mod-php5
  php5
  php5-cli
  php5-dev
  php5-mysql
  php5-pgsql
  php5-sqlite
  php5-sqlite3
HERE

["/etc/php5/cli/php.ini", "/etc/php5/apache2/php.ini"].each do |filename|
  edit(filename, :locals => {
      :memory_limit => memory_limit,
      :upload_max_filesize => upload_max_filesize,
  }) do
    line = "memory_limit = #{memory_limit}; Maximum amount of memory a script may consume"
    unless contains?(line)
      comment /^memory_limit /
      append line
    end

    line = "upload_max_filesize = #{upload_max_filesize}; # Maximum allowed size for uploaded files."
    unless contains?(line)
      comment /^upload_max_filesize /
      append line
    end
  end
end
