# Setup PHP5
#
# NOTE: Can set memory based on "php5#memory_limit" field.

memory_limit = lookup("php5#memory_limit") rescue "64M"

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

edit_memory_limit_in = lambda do |filename|
  edit(filename, :locals => {:memory_limit => memory_limit}) do
    line = "memory_limit = #{memory_limit}; Maximum amount of memory a script may consume"
    unless contains?(line)
      comment /^memory_limit /
      append line
    end
  end
end

edit_memory_limit_in.call("/etc/php5/apache2/php.ini")
edit_memory_limit_in.call("/etc/php5/cli/php.ini")
