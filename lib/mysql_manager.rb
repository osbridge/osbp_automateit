# = MysqlManager
#
# Manage MySQL database server.
#
# == Usage
#
#   # Load this library and instantiate it
#   load 'lib/mysql_manager.rb'
#   mysql_manager = MysqlManager.new(self)
#
#   # Setup MySql server, client and libraries
#   mysql_manager.setup
#
#   # Is there a "root" user on "localhost" with superuser privileges?
#   mysql_manager.superuser?("root", :host => "localhost")
#
#   # Add user with login "asdf" at "localhost" with password "meh"
#   mysql_manager.add_user("asdf", :host => "localhost", :password => "meh")
#
#   # Grant super user privileges to user "asdf" at "localhost"
#   mysql_manager.grant_superuser("asdf", :host => "localhost", :password => "meh")
#
#   # Revoke superuser privileges from user "asdf" at "localhost"
#   mysql_manager.revoke_superuser("asdf", :host => "localhost")
#
#   # Remove user "asdf" at "localhost"
#   mysql_manager.remove_user("asdf", :host => "localhost")
class MysqlManager
  # Include constants like PNOTE
  # TODO add Interpreter#PNOTE to avoid needing constants
  include AutomateIt::Constants

  # AutomateIt interpreter object
  attr_accessor :interpreter

  # Default database that's always available, e.g., "template1"
  attr_accessor :default_db

  # Database connection handle
  attr_accessor :dbh

  # Database administrator's username
  attr_accessor :dba

  # Initialize a setup object.
  #
  # Options:
  # * :interpreter => AutomateIt interpreter object. Required.
  # * :default_db => Default database that's always available. Defaults to "mysql".
  # * :dba => Database administrator's username. Defaults to "root".
  def initialize(interpreter, opts={})
    self.interpreter = interpreter
    self.default_db = opts[:default_db] || "mysql"
    self.dba = opts[:dba] || "root"

  end

  # Setup MySQL by installing packages and activating its service.
  def setup
    modified = false
    modified |= self.install_packages
    modified |= self.activate_service(modified)
    return modified
  end

  # Install MySQL server, client and libraries.
  def install_packages
    modified = false 
    
    modified |= interpreter.package_manager.install <<-HERE
      # Core
      mysql-server
      mysql-client

      # Tools
      libcompress-zlib-perl
      mytop

      # Ruby drivers
      libmysqlclient15-dev
      libmysql-ruby
      libdbd-mysql-ruby
    HERE

    modified |= interpreter.package_manager.install <<-HERE, :with => :gem
      dbi
      dbd-mysql
    HERE

    return modified
  end

  # Start and enable the MySQL server.
  def activate_service(modified=false)
    service = "mysql"
    modified |= interpreter.service_manager.enable(service)
    modified |= interpreter.service_manager.start(service)
    return modified
  end

  # Connect to the database.
  def connect
    return self.dbh if self.dbh && self.dbh.connected?
    begin
      Gem.clear_paths rescue nil
      require 'dbi'
      return self.dbh = ::DBI.connect("dbi:Mysql:dbname=#{default_db}")
    rescue LoadError => e
      if self.interpreter.writing?
        raise e
      else
        return false
      end
    rescue ::DBI::OperationalError => e
      if self.interpreter.writing?
        raise e
      else
        return false
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
    return nil if ! self.connected? && self.interpreter.preview?
    begin
      sth = self.dbh.prepare(sql)
      if params.empty?
        sth.execute
      else
        sth.execute(*params)
      end
      return sth
    rescue ::DBI::ProgrammingError => e
      raise "#{e.message} -- #{sql}"
    end
  end

  # Fetch data from database using +sql+. The +params+ as defined by DBI's
  # statement handle #execute method, which are typically positional arguments.
  def fetch(sql, *params)
    rs = self.execute(sql, *params)
    self.execute("flush privileges") # Always flush in case user wants to alter users
    return [] if self.interpreter.preview? && ! rs
    return rs.fetch_all rescue nil
  end

  # Return an array of column names for a given SQL statement.
  def columns(sql)
    return self.dbh.execute(sql).column_names
  end

  # Does the +user+ have superuser privileges?
  #
  # Options:
  # * :host => Hostname to restrict access to.
  def superuser?(user, opts={})
    unh = self._user_and_host(user, opts[:host])
    row = self.user?(user, opts)
    return false unless row
    return row['Super_priv'] == 'Y'
  end

  # Does the +user+ exist in the database? Returns either the user or nil.
  #
  # Options:
  # * :host => Hostname to restrict access to.
  def user?(user, opts={})
    rs = self.fetch("select * from mysql.user where User = ? and Host = ?", user, opts[:host] || "%")
    return rs.first
  end

  # Add +user+ to the database.
  #
  # Options:
  # * :host => Hostname to restrict access to.
  # * :password => Password to associate with user.
  def add_user(user, opts={})
    return false  if self.user?(user, opts)
    unh = self._user_and_host(user, opts[:host])
    self.interpreter.log.info(PNOTE+"Added MySQL user: #{unh}")
    sql = "create user #{unh}"
    sql << " identified by '#{opts[:password]}'" if opts[:password]
    fetch(sql) if self.interpreter.writing?
    return true
  end

  # Remove +user+ from database.
  #
  # Options:
  # * :host => Hostname to restrict access to.
  def remove_user(user, opts={})
    return false unless user?(user, opts)
    unh = self._user_and_host(user, opts[:host])
    self.interpreter.log.info(PNOTE+"Removed MySQL user: #{unh}")
    self.fetch("delete from mysql.user where User = ? and Host = ?", user, opts[:host] || "%") if self.interpreter.writing?
    return true
  end

  # Grant superuser privileges to +user+.
  #
  # Options:
  # * :host => Hostname to restrict access to.
  # * :password => Password to associate with user. Optional.
  def grant_superuser(user, opts={})
    return false if self.superuser?(user, opts)
    unh = self._user_and_host(user, opts[:host])
    self.interpreter.log.info(PNOTE+"Granted superuser rights to MySQL user: #{unh}")
    sql = "grant all privileges on *.* to #{unh}"
    sql << " identified by '#{opts[:password]}'" if opts[:password]
    self.fetch(sql) if self.interpreter.writing?
    return true
  end

  # Revoke superuser privileges from +user+.
  def revoke_superuser(user, opts={})
    return false unless self.superuser?(user, opts)
    unh = self._user_and_host(user, opts[:host])
    self.interpreter.log.info(PNOTE+"Revoked superuser rights from MySQL user: #{unh}")
    self.fetch("revoke all on *.* from #{unh}") if self.interpreter.writing?
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

__END__
load 'lib/mysql_manager.rb'
mysql_manager = MysqlManager.new(self); 1
m = mysql_manager; 1
m.setup
m.superuser?("root", :host => "localhost")
m.add_user("asdf", :host => "localhost", :password => "meh")
m.grant_superuser("asdf", :host => "localhost")
m.revoke_superuser("asdf", :host => "localhost")
m.remove_user("asdf", :host => "localhost")
