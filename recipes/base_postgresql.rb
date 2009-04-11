# Setup PostgreSQL database server
#
# Creates database accounts from fields at "postgresql#accounts", a hash of
# usernames to a hash of "password" strings and "superuser" booleans.
#
# For example, the following fields will add a user with login "MyUsername",
# set their password to "MyPassword", and give them superuser privileges:
#
#       postgresql:
#         accounts:
#           "MyUsername":
#             password: "MyPassword"
#             superuser: true

# Setup PostgreSQL server, client and libraries
postgresql_manager.setup

# Manage accounts
lookup("postgresql#accounts").each_pair do |username, opts|
  postgresql_manager.add_user(username, :password => opts["password"])
  postgresql_manager.grant_superuser(username) if opts["superuser"]
end
