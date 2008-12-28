# = PostgreSQLSetup
#
# Setup PostgreSQL database.
#
# NOTE: Requires Ruby 'dbi' package and bindings.
class ::PostgreSQLSetup
  include AutomateIt::Constants

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
  def initialize(opts={})
    require 'dbi'
    self.interpreter = opts[:interpreter] or raise ArgumentError.new(":interpreter not specified")
    self.interpreter.include_in(self, %w[writing? sh preview? log])
    self.default_db = opts[:default_db] || "template1"
    self.dba = opts[:dba] || "postgres"
  end

  # Run block with an instance as argument. Ensures that database connection
  # is closed when block ends or an exception is raised. Accepts same
  # arguments as #new.
  def self.with(*args, &block)
    instance = self.new(*args)
    begin
      instance.connect
      block.call(instance)
    ensure
      instance.close rescue nil
    end
  end

  # Connect to the database
  def connect
    return dbh if dbh and dbh.connected?
    begin
      return self.dbh = DBI.connect("dbi:Pg:dbname=#{default_db}")
    rescue DBI::OperationalError => e
      if writing?
        raise e
      else
        return false
      end
    end
  end

  # Connect to the database and add a superuser if needed
  def connect_or_add_superuser
    begin
      tried = false
      return connect
    rescue DBI::OperationalError => e
      sh %q(echo "create user #{root} with superuser;" | su - #{dba} -- psql -d #{default_db})
      if preview?
        log.info(PNOTE+"Granting superuser rights to root")
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
    return dbh && dbh.connected?
  end

  # Close database connection.
  def close
    return false unless connected?
    return dbh.disconnect
  end

  # Execute a line of +sql+. The +params+ as defined by DBI's statement handle
  # #execute method, which are typically positional arguments.
  def execute(sql, *params)
    connect
    return nil if not connected? and preview?
    begin
      sth = dbh.prepare(sql)
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
    rs = execute(sql, *params)
    return [] if preview? and not rs
    return rs.fetch_all
  end

  # Return an array of column names for a given SQL statement.
  def columns(sql)
    return dbh.execute(sql).column_names
  end

  # Does the +user+ have superuser privileges?
  def superuser?(user)
    rs = fetch "select * from pg_user where usename = ?", user
    return false if rs.empty?
    return rs.first['usesuper']
  end

  # Does the +user+ exist in the database?
  def user?(user)
    rs = fetch "select * from pg_user where usename = ?", user
    return ! rs.empty?
  end

  # Add +user+ to the database.
  #
  # Options:
  # * :password => Password to associate with user.
  def add_user(user, opts={})
    return false if user? user
    sql = "create user #{user}"
    sql << " password '#{opts[:password]}'" if opts[:password]
    log.info PNOTE+"Added PostgreSQL user: #{user}"
    fetch sql if writing?
  end

  # Remove +user+ from database.
  def remove_user(user)
    return false unless user? user
    log.info PNOTE+"Removed PostgreSQL user: #{user}"
    fetch "drop user #{user}" if writing?
  end

  # Grant superuser privileges to +user+.
  def grant_superuser(user)
    return false if superuser? user
    log.info PNOTE+"Granted superuser rights to PostgreSQL user: #{user}"
    fetch "alter user #{user} createuser" if writing?
  end

  # Revoke superuser privileges from +user+.
  def revoke_superuser(user)
    return false unless superuser? user
    log.info PNOTE+"Revoked superuser rights from PostgreSQL user: #{user}"
    fetch "alter user #{user} nocreateuser" if writing?
  end

  # Is a procedural +language+ installed?
  def language?(language)
    rs = fetch "select * from pg_language where lanname = ?", language
    return ! rs.empty?
  end

  # Add a procedural +language+.
  def add_language(language)
    log.info PNOTE+"Added PostgreSQL language: #{language}"
    fetch "create language #{language}" if writing?
  end

  # Remove a procedural +language+.
  def remove_language(language)
    log.info PNOTE+"Removed PostgreSQL language: #{language}"
    fetch "drop language #{language}" if writing?
  end
end

=begin
# Commands to exercise this class:

load 'lib/postgresql_setup.rb'
db = PostgreSQLSetup.new(:interpreter => self)
db.connect_or_add_superuser
db.superuser?("root")

db.add_user("asdf")
db.grant_superuser("asdf")
db.revoke_superuser("asdf")
db.remove_user("asdf")
=end
