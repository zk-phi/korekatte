require 'active_record'

module DB

  def self.connect(mode)
    if mode == "production"
      begin
        uri = URI.parse(ENV['DATABASE_URL'])
      rescue
        raise "Invalid DATABASE_URL"
      end
      ActiveRecord::Base.establish_connection({
          :adapter => uri.scheme != "postgres" ? uri.scheme : "postgresql",
          :database => uri.path.split("/")[1],
          :username => uri.user,
          :password => uri.password,
          :host => uri.host,
          :port => uri.port
        })
    else
      ActiveRecord::Base.establish_connection({
          :adapter => 'sqlite3',
          :database => 'db/sqlite.db'
        })
    end
  end

  def self.close
    ActiveRecord::Base.connection.close
  end

end
