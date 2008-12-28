# Setup MySQL database server
#
# NOTE:
# - Relies on "lib/mysql_setup.rb" for MySQLSetup class.
# - Creates database accounts from fields at "postgresql#accounts". This leaf
#   contains a hash of usernames to a hash of "password" strings and "superuser"
#   booleans. For example:
#       postgresql:
#         accounts:
#           "myusername":
#             password: "mypassword"
#             superuser: true

package_manager.install <<-HERE
  # Core
  mysql-server
  mysql-client

  # Tools
  libcompress-zlib-perl
  mytop
  dbishell

  # Ruby drivers
  libmysql-ruby
  libdbd-mysql-ruby
HERE

service = "mysql"
service_manager.enable(service)
service_manager.start(service)

# Manage accounts
begin
  MySQLSetup.with(:interpreter => self) do |db|
    db.connect_or_add_superuser
    lookup("mysql#accounts").each_pair do |username, opts|
      db.add_user(username, :password => opts["password"])
      db.grant_superuser(username) if opts["superuser"]
    end
  end
rescue LoadError => e
  if preview? and e.message =~ /\bdbi\b/
    puts PERROR+"Can't check MySQL because 'dbi' Gem isn't installed yet"
  else
    raise e
  end
end
