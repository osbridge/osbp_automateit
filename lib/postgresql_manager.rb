=begin
= PostgresqlManager

Manage PostgreSQL database server.

== Usage

  # Load this library and instantiate it
  load 'lib/postgresql_manager.rb'
  postgresql_manager = PostgresqlManager.new(self)

  # Setup server, client and libraries
  postgresql_manager.setup

  # Is there a "root" user?
  postgresql_manager.superuser?("root")

  # Add an "asdf" user
  postgresql_manager.add_user("asdf")

  # Grant superuser privileges to user "asdf"
  postgresql_manager.grant_superuser("asdf")

  # Revoke superuser privileges from user "asdf"
  postgresql_manager.revoke_superuser("asdf")

  # Remove user "asdf"
  postgresql_manager.remove_user("asdf")
=end
class PostgresqlManager
  # Include constants like PNOTE
  # TODO provide Interpreter#PNOTE
  include AutomateIt::Constants

  # PostgreSQL version, e.g. "8.3"
  attr_accessor :postgresql_version

  # PostgreSQL service name, e.g. "postgresql-8.3"
  attr_accessor :postgresql_service

  # Path to "postgresql.conf"
  attr_accessor :configuration_file

  # Default database that's always available, e.g., "template1"
  attr_accessor :default_db

  # Database connection handle
  attr_accessor :dbh

  # Database administrator's username
  attr_accessor :dba

  # AutomateIt interpreter object
  attr_accessor :interpreter

  # Initialize a setup object.
  #
  # Options:
  # * :interpreter => AutomateIt interpreter object. Required.
  # * :default_db => Default database that's always available. Defaults to "template1".
  # * :dba => Database administrator's username. Defaults to "postgres".
  def initialize(interpreter, opts={})
    self.interpreter = interpreter
    self.default_db = opts[:default_db] || "template1"
    self.dba = opts[:dba] || "postgres"

    # Calculate values
    self.postgresql_version = \
      if self.interpreter.tagged? 'ubuntu_8.04 | ubuntu_8.10 | ubuntu_9.04'
        '8.3'
      elsif self.interpreter.tagged? 'ubuntu_7.10'
        '8.2'
      elsif self.interpreter.tagged? 'ubuntu_6.06 | ubuntu_6.10 | ubuntu_7.04'
        '8.1'
      else
        raise NotImplementedError, "PostgreSQL package not know for this platform"
      end
    self.postgresql_service = "postgresql-#{self.postgresql_version}"
    self.configuration_file = "/etc/postgresql/#{self.postgresql_version}/main/postgresql.conf"
  end

  # Setup PostgreSQL by installing packages, editing its configuration file,
  # activating its service, and adding a superuser.
  #
  # Options:
  # * :shared_buffers => Number of shared buffers, e.g. "8000"
  # * :work_mem =>  Amount of work memory in KB, e.g., "4096"
  def setup(opts={})
    modified = false
    modified |= self.install_packages
    modified |= self.edit_configuration(opts)
    modified |= self.activate(modified)
    modified |= self.add_superuser
    return modified
  end

  # Install PostgreSQL server, client and libraries
  def install_packages
    return(self.interpreter.package_manager.install <<-HERE)
      # PostgreSQL
      postgresql-#{self.postgresql_version}
      postgresql-client-#{self.postgresql_version}
      postgresql-server-dev-#{self.postgresql_version}
      libpq-dev

      # Ruby libraries
      libdbd-pg-ruby1.8
      libdbd-pg-ruby

      # Helpers
      oidentd
    HERE
  end

  # Edit "postgresql.conf" file.
  #
  # Options:
  # * :shared_buffers => Number of shared buffers, e.g. "8000"
  # * :work_mem =>  Amount of work memory in KB, e.g., "4096"
  def edit_configuration(opts={})
    self.interpreter.edit(
        self.configuration_file,
        :mode => 0644,
        :user => self.dba,
        :group => self.dba,
        :locals => opts
    ) do
      shared_buffers = opts[:shared_buffers] || "8000 # ~64MB := 8000 * 8K"
      work_mem = opts[:work_mem] || "4096 # 4MB for sorts before spilling to disk based sort-merge"

      comment_style "#"
      shared_buffers_string = "shared_buffers = #{shared_buffers}"
      work_mem_string = "work_mem = #{work_mem}"

      unless contains?(shared_buffers_string)
        comment "shared_buffers"
        append shared_buffers_string
      end

      unless contains?(work_mem_string)
        comment "work_mem"
        append work_mem_string
      end
    end
  end

  # Start and enable PostgreSQL service.
  def activate(modified=false)
    if modified and self.interpreter.service_manager.started?(self.postgresql_service)
      modified |= self.interpreter.service_manager.tell(self.postgresql_service, "restart")
    else
      modified |= self.interpreter.service_manager.start(self.postgresql_service)
    end
    modified |= self.interpreter.service_manager.enable(self.postgresql_service)
    return modified
  end

  # Connect to the database.
  def connect
    return self.dbh if self.dbh && self.dbh.connected?
    begin
      Gem.clear_paths rescue nil
      require 'dbi'
      return self.dbh = DBI.connect("dbi:Pg:dbname=#{default_db}")
    rescue DBI::OperationalError => e
      if self.interpreter.writing?
        raise e
      else
        return false
      end
    end
  end

  # Connect to the database and add a superuser if needed
  def add_superuser
    begin
      tried = false
      return self.connect
    rescue DBI::OperationalError => e
      self.interpreter.sh(%Q(echo "create user root with superuser;" | su - #{self.dba} -c "psql -d #{self.default_db}"))
      if self.interpreter.preview?
        self.interpreter.log.info(PNOTE+"Granting superuser rights to root")
        return false
      elsif tried
        raise e
      else
        tried = true
        retry
      end
    end
  end

  # Connected to database?
  def connected?
    return self.dbh && self.dbh.connected?
  end

  # Close database connection.
  def close
    return false unless self.connected?
    return self.dbh.disconnect
  end

  # Execute a line of +sql+. The +params+ as defined by DBI's statement handle
  # #execute method, which are typically positional arguments.
  def execute(sql, *params)
    self.connect
    return nil if not self.connected? and self.interpreter.preview?
    begin
      sth = self.dbh.prepare(sql)
      if params.empty?
        sth.execute
      else
        sth.execute(*params)
      end
      return sth
    rescue DBI::ProgrammingError => e
      raise "#{e.message} -- #{sql}"
    end
  end

  # Fetch data from database using +sql+. The +params+ as defined by DBI's
  # statement handle #execute method, which are typically positional arguments.
  def fetch(sql, *params)
    rs = self.execute(sql, *params)
    return [] if self.interpreter.preview? and not rs
    return rs.fetch_all
  end

  # Return an array of column names for a given SQL statement.
  def columns(sql)
    return self.dbh.execute(sql).column_names
  end

  # Does the +user+ have superuser privileges?
  def superuser?(user)
    rs = self.fetch("select * from pg_user where usename = ?", user)
    return false if rs.empty?
    return rs.first['usesuper']
  end

  # Does the +user+ exist in the database?
  def user?(user)
    rs = self.fetch("select * from pg_user where usename = ?", user)
    return ! rs.empty?
  end

  # Add +user+ to the database.
  #
  # Options:
  # * :password => Password to associate with user.
  def add_user(user, opts={})
    return false if self.user?(user)
    sql = "create user #{user}"
    sql << " password '#{opts[:password]}'" if opts[:password]
    self.interpreter.log.info(PNOTE+"Added PostgreSQL user: #{user}")
    self.fetch(sql) if self.interpreter.writing?
    return true
  end

  # Remove +user+ from database.
  def remove_user(user)
    return false unless self.user?(user)
    self.interpreter.log.info(PNOTE+"Removed PostgreSQL user: #{user}")
    self.fetch("drop user #{user}") if self.interpreter.writing?
    return true
  end

  # Grant superuser privileges to +user+.
  def grant_superuser(user)
    return false if self.superuser?(user)
    self.interpreter.log.info(PNOTE+"Granted superuser rights to PostgreSQL user: #{user}")
    self.fetch("alter user #{user} createuser") if self.interpreter.writing?
    return true
  end

  # Revoke superuser privileges from +user+.
  def revoke_superuser(user)
    return false unless self.superuser?(user)
    self.interpreter.log.info(PNOTE+"Revoked superuser rights from PostgreSQL user: #{user}")
    self.fetch("alter user #{user} nocreateuser") if self.interpreter.writing?
    return true
  end

  # Is a procedural +language+ installed?
  def language?(language)
    rs = self.fetch("select * from pg_language where lanname = ?", language)
    return ! rs.empty?
  end

  # Add a procedural +language+.
  def add_language(language)
    return false if self.language(language)
    self.interpreter.log.info(PNOTE+"Added PostgreSQL language: #{language}")
    self.fetch("create language #{language}") if self.interpreter.writing?
    return true
  end

  # Remove a procedural +language+.
  def remove_language(language)
    return false unless self.language(language)
    self.interpreter.log.info(PNOTE+"Removed PostgreSQL language: #{language}")
    self.fetch("drop language #{language}") if self.interpreter.writing?
    return true
  end
end

__END__
load 'lib/postgresql_manager.rb'
postgresql_manager = PostgresqlManager.new(self); 1
m = postgresql_manager; 1
m.setup
m.superuser?("root")
m.add_user("asdf")
m.grant_superuser("asdf")
m.revoke_superuser("asdf")
m.remove_user("asdf")
