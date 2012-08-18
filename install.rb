require 'fileutils'
FileUtils.cp(
  File.join(File.dirname(__FILE__), "bin", "dbdump"),
  File.join(Rails.root, "script", "dbdump"),
  :preserve => true) # copy +x
