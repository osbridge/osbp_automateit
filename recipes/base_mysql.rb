# Setup MySQL database server
#
# Creates database accounts from fields at "mysql#accounts", a hash of
# usernames to a hash of "password" strings and "superuser" booleans.
#
# For example, the following fields will add a user with login "MyUsername",
# set their password to "MyPassword", and give them superuser privileges:
#
#      mysql:
#        accounts:
#          "MyUsername":
#            password: "MyPassword"
#            superuser: true

# Setup MySQL server, client and libraries
mysql_manager.setup

# Create accounts and grant privileges
lookup("mysql#accounts").each_pair do |username, opts|
  mysql_manager.add_user(username, :password => opts["password"])
  mysql_manager.grant_superuser(username) if opts["superuser"]
end
