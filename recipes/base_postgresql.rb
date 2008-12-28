# Setup PostgreSQL database server
#
# NOTE:
# - Relies on "lib/postgresql_setup.rb" for PostgreSQLSetup class
# - Creates database accounts from fields at "postgresql#accounts". This leaf
#   contains a hash of usernames to a hash of "password" strings and "superuser"
#   booleans. For example:
#       postgresql:
#         accounts:
#           "myusername":
#             password: "mypassword"
#             superuser: true

# Define version number to install
postgres_package_version = \
  if tagged? 'ubuntu_8.04'
    '8.3'
  elsif tagged? 'ubuntu_7.10'
    '8.2'
  elsif tagged? 'ubuntu_6.06 | ubuntu_6.10 | ubuntu_7.04'
    '8.1'
  else
    raise NotImplementedError, "PostgreSQL package not know for this platform"
  end
service = "postgresql-#{postgres_package_version}"

# Install packages
package_manager.install <<HERE
  # PostgreSQL
  postgresql-#{postgres_package_version}
  postgresql-client-#{postgres_package_version}
  postgresql-server-dev-#{postgres_package_version}
  libpq-dev

  # Ruby libraries
  libdbd-pg-ruby1.8
  libdbd-pg-ruby

  # Helpers
  oidentd
HERE

# Provide reasonable settings
modified = edit("/etc/postgresql/#{postgres_package_version}/main/postgresql.conf", :mode => 0644, :user => "postgres", :group => "postgres") do
  comment_style "#"
  shared_buffers = "shared_buffers = 8000 # ~64MB := 8000 * 8K"
  work_mem = "work_mem = 4096 # 4MB for sorts before spilling to disk based sort-merge"

  unless contains?(shared_buffers)
    comment "shared_buffers"
    append shared_buffers
  end

  unless contains?(work_mem)
    comment "work_mem"
    append work_mem
  end
end

# Manage service
if modified and service_manager.started?(service)
  service_manager.tell(service, "restart")
else
  service_manager.start(service)
end
service_manager.enable(service)

# Manage accounts
begin
  PostgreSQLSetup.new(:interpreter => self) do |db|
    db.connect_or_add_superuser
    lookup("postgresql#accounts").each_pair do |username, opts|
      db.add_user(username, :password => opts["password"])
      db.grant_superuser(username) if opts["superuser"]
    end
  end
rescue LoadError => e
  if preview? and e.message =~ /\bdbi\b/
    puts PERROR+"Can't check PostgreSQL because 'dbi' Gem isn't installed yet"
  else
    raise e
  end
end
