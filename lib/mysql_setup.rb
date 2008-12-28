# = MySQLSetup
#
# Setup MySQL database.
#
# NOTE: Requires that the 'dbi' Ruby package be installed with MySQL bindings.
class ::MySQLSetup
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
  # * :default_db => Default database that's always available. Defaults to "mysql".
  # * :dba => Database administrator's username. Defaults to "root".
  def initialize(opts={})
    require 'dbi'
    self.interpreter = opts[:interpreter] or raise ArgumentError.new(":interpreter not specified")
    self.interpreter.include_in(self, %w[writing? sh preview? log])
    self.default_db = opts[:default_db] || "mysql"
    self.dba = opts[:dba] || "root"
  end

  # Run block with an instance of MySQLSetup as argument. Ensures that database
  # connection is closed when block ends or an exception is raised.
  def self.with(opts={}, &block)
    instance = self.new(opts)
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
      return self.dbh = DBI.connect("dbi:Mysql:dbname=#{default_db}")
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
    return connect
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
    execute("flush privileges") # Always flush in case user wants to alter users
    return [] if preview? and not rs
    return rs.fetch_all rescue nil
  end

  # Return an array of column names for a given SQL statement.
  def columns(sql)
    return dbh.execute(sql).column_names
  end

  # Does the +user+ have superuser privileges?
  #
  # Options:
  # * :host => Hostname to restrict access to.
  def superuser?(user, opts={})
    unh = self._user_and_host(user, opts[:host])
    row = user?(user, opts)
    return false unless row
    return row['Super_priv'] == 'Y'
  end

  # Does the +user+ exist in the database? Returns either the user or nil.
  #
  # Options:
  # * :host => Hostname to restrict access to.
  def user?(user, opts={})
    rs = fetch "select * from mysql.user where User = ? and Host = ?", user, opts[:host] || "%"
    return rs.first
  end

  # Add +user+ to the database.
  #
  # Options:
  # * :host => Hostname to restrict access to.
  # * :password => Password to associate with user.
  def add_user(user, opts={})
    return false if user?(user, opts)
    unh = self._user_and_host(user, opts[:host])
    log.info PNOTE+"Added MySQL user: #{unh}"
    sql = "create user #{unh}"
    sql << " identified by '#{opts[:password]}'" if opts[:password]
    fetch sql if writing?
  end

  # Remove +user+ from database.
  #
  # Options:
  # * :host => Hostname to restrict access to.
  def remove_user(user, opts={})
    return false unless user?(user, opts)
    unh = self._user_and_host(user, opts[:host])
    log.info PNOTE+"Removed MySQL user: #{unh}"
    fetch("delete from mysql.user where User = ? and Host = ?", user, opts[:host] || "%") if writing?
    return true
  end

  # Grant superuser privileges to +user+.
  #
  # Options:
  # * :host => Hostname to restrict access to.
  # * :password => Password to associate with user.
  def grant_superuser(user, opts={})
    return false if superuser?(user, opts)
    unh = self._user_and_host(user, opts[:host])
    log.info PNOTE+"Granted superuser rights to MySQL user: #{unh}"
    fetch "grant all privileges on *.* to #{unh} identified by '#{opts[:password]}'" if writing?
    return true
  end

  # Revoke superuser privileges from +user+.
  def revoke_superuser(user, opts={})
    return false unless superuser?(user, opts)
    unh = self._user_and_host(user, opts[:host])
    log.info PNOTE+"Revoked superuser rights from MySQL user: #{unh}"
    fetch "revoke all on *.* from #{unh}" if writing?
    return true
  end

  def self._user_and_host(user, host=nil)
    s = "'#{user}'"
    s << "@'#{host}'" if host
    return s
  end

  def _user_and_host(*args)
    return self.class._user_and_host(*args)
  end
end

=begin
# Commands to exercise this class:

load 'lib/mysql_setup.rb'
db = MySQLSetup.new(:interpreter => self)
db.connect_or_add_superuser
db.superuser?("root", :host => "localhost")

db.add_user("asdf", :host => "localhost", :password => "meh")
db.grant_superuser("asdf", :host => "localhost", :password => "meh")
db.revoke_superuser("asdf", :host => "localhost")
db.remove_user("asdf", :host => "localhost")
=end
