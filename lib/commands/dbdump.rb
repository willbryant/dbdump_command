require 'erb'
require 'yaml'
require 'optparse'

module Rails
  class DBDump
    def self.start(app)
      new(app).start
    end

    def initialize(app)
      @app = app
    end

    def start
      include_password = false
      options = {}
      OptionParser.new do |opt|
        opt.banner = "Usage: dbdump [options] [environment]"
        opt.on("-p", "--include-password", "Automatically provide the password from database.yml") do |v|
          include_password = true
        end

        opt.parse!(ARGV)
        abort opt.to_s unless (0..1).include?(ARGV.size)
      end

      env = ARGV.first || Rails.env
      unless config = YAML::load(ERB.new(IO.read("#{@app.root}/config/database.yml")).result)[env]
        abort "No database is configured for the environment '#{env}'"
      end


      def find_cmd(*commands)
        dirs_on_path = ENV['PATH'].to_s.split(File::PATH_SEPARATOR)
        commands += commands.map{|cmd| "#{cmd}.exe"} if RbConfig::CONFIG['host_os'] =~ /mswin|mingw/

        full_path_command = nil
        found = commands.detect do |cmd|
          dir = dirs_on_path.detect do |path|
            full_path_command = File.join(path, cmd)
            File.executable? full_path_command
          end
        end
        found ? full_path_command : abort("Couldn't find database client: #{commands.join(', ')}. Check your $PATH and try again.")
      end

      case config["adapter"]
      when /^mysql/
        args = {
          'host'      => '--host',
          'port'      => '--port',
          'socket'    => '--socket',
          'username'  => '--user',
          'encoding'  => '--default-character-set'
        }.map { |opt, arg| "#{arg}=#{config[opt]}" if config[opt] }.compact

        if config['password'] && include_password
          args << "--password=#{config['password']}"
        elsif config['password'] && !config['password'].to_s.empty?
          args << "-p"
        end

        args << config['database']

        exec(find_cmd('mysqldump', 'mysql5dump'), "--single-transaction", *args)

      when "postgresql"
        ENV['PGUSER']     = config["username"] if config["username"]
        ENV['PGHOST']     = config["host"] if config["host"]
        ENV['PGPORT']     = config["port"].to_s if config["port"]
        ENV['PGPASSWORD'] = config["password"].to_s if config["password"] && include_password
        
        args = {
          'encoding'  => '--encoding'
        }.map { |opt, arg| "#{arg}=#{config[opt]}" if config[opt] }.compact
        
        args << config["database"]
        
        exec(find_cmd('pg_dump'), *args)

      when "sqlite"
        exec(find_cmd('sqlite'), config["database"], ".dump")

      when "sqlite3"
        args = []

        args << "-#{options['mode']}" if options['mode']
        args << "-header" if options['header']
        args << config['database']
        args << ".dump"

        exec(find_cmd('sqlite3'), *args)

      else
        abort "Unknown command-line dump client for #{config['database']}. Submit a dbdump patch to add support!"
      end
    end
  end
end

# Has to set the RAILS_ENV before config/application is required
if ARGV.first && !ARGV.first.index("-") && env = ARGV.first
  ENV['RAILS_ENV'] = %w(production development test).find { |e| e.index(env) } || env
end
