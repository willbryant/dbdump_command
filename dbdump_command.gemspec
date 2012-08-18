# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dbdump_command/version', __FILE__)

spec = Gem::Specification.new do |gem|
  gem.name         = 'dbdump_command'
  gem.version      = DbdumpCommand::VERSION
  gem.summary      = "Adds support for displaying your ActiveRecord tables, named scopes, collections, or plain arrays in a table view when working in script/console, shell, or email template."
  gem.description  = <<-EOF
This plugin adds a dbdump command which dumps your Rails database out.

This master branch supports Rails 3.0 and above, as a gem command.
For Rails 2.3, use the rails_2_3 branch from github and install as a plugin.

Like rails dbconsole, it takes your database connection details from
config/database.yml, and supports mysql, mysql2, postgresql, and sqlite.

It takes the same options as rails dbconsole, ie. -p to supply the password
to your dump program for mysql and postgresql.   (Note that for mysql, this
means that the password is visible when other users on the system run 'ps'.
Postgresql does not have this problem as it uses an environment variable set
in ENV before execing and so not visible in ps.)
EOF
  gem.has_rdoc     = false
  gem.author       = "Will Bryant"
  gem.email        = "will.bryant@gmail.com"
  gem.homepage     = "http://github.com/willbryant/dbdump_command"
  
  gem.executables  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files        = `git ls-files`.split("\n")
  gem.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_path = "lib"

  gem.add_dependency 'activerecord'  
  gem.add_development_dependency "rake"
end
