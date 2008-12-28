# Setup PostgreSQL database
class ::PostgreSQLSetup
  include AutomateIt::Constants

  attr_accessor :default_db
  attr_accessor :dbh
  attr_accessor :dba
  attr_accessor :interpreter

  def initialize(opts={})
    require 'dbi'

    @interpreter = opts[:interpreter] or raise ArgumentError.new(":interpreter not specified")
    @interpreter.include_in(self, %w[writing? sh preview? log])
    @default_db = opts[:default_db] || "template1"
    @dba = opts[:dba] || "postgres"
  end

  def connect
    return dbh if dbh and dbh.connected?
    begin
      return @dbh = DBI.connect("dbi:Pg:dbname=#{default_db}")
    rescue DBI::OperationalError => e
      if writing?
        raise e
      else
        return false
      end
    end
  end

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

  def connected?
    return dbh && dbh.connected?
  end

  def close
    return false unless connected?
    return dbh.disconnect
  end

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

  def fetch(sql, *params)
    rs = execute(sql, *params)
    return [] if preview? and not rs
    return rs.fetch_all
  end

  def columns(sql)
    return dbh.execute(sql).column_names
  end

  def superuser?(user)
    rs = fetch "select * from pg_user where usename = ?", user
    return false if rs.empty?
    return rs.first['usesuper']
  end

  def user?(user)
    rs = fetch "select * from pg_user where usename = ?", user
    return ! rs.empty?
  end

  def add_user(user, opts={})
    return false if user? user
    sql = "create user #{user}"
    sql << " password '#{opts[:password]}'" if opts[:password]
    log.info PNOTE+"Added PostgreSQL user: #{user}"
    fetch sql if writing?
  end

  def remove_user(user)
    return false unless user? user
    log.info PNOTE+"Removed PostgreSQL user: #{user}"
    fetch "drop user #{user}" if writing?
  end

  def grant_superuser(user)
    return false if superuser? user
    log.info PNOTE+"Granted superuser rights to PostgreSQL user: #{user}"
    fetch "alter user #{user} createuser" if writing?
  end

  def revoke_superuser(user)
    return false unless superuser? user
    log.info PNOTE+"Revoked superuser rights from PostgreSQL user: #{user}"
    fetch "alter user #{user} nocreateuser" if writing?
  end

  def language?(language)
    rs = fetch "select * from pg_language where lanname = ?", language
    return ! rs.empty?
  end

  def add_language(language)
    log.info PNOTE+"Added PostgreSQL language: #{language}"
    fetch "create language #{language}" if writing?
  end

  def remove_language(language)
    log.info PNOTE+"Removed PostgreSQL language: #{language}"
    fetch "drop language #{language}" if writing?
  end
end

=begin
# Commands to exercise this class:

load 'lib/postgresql_setup.rb'
pg = PostgreSQLSetup.new(:interpreter => self)
pg.connect_or_add_superuser
pg.superuser?("root")

pg.add_user("asdf")
pg.grant_superuser("asdf")
pg.revoke_superuser("asdf")
pg.remove_user("asdf")
=end
