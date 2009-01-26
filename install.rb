require 'fileutils'
FileUtils.cp(
  File.join(File.dirname(__FILE__), "src", "dbdump"),
  File.join(RAILS_ROOT, "script", "dbdump"),
  :preserve => true) # copy +x
