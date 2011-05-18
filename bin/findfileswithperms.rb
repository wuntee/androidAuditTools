#!/usr/bin/env ruby

$:.push("../src/")

require 'androidtools'
require 'rubygems'
require 'trollop'

def recur(dir, regex)
  AndroidTools.listDirectory(dir).each do |f|
    if(!f.name.nil?)
      if(!f.perm.match(regex).nil?)
        puts(f.to_s_full)
      end
      if(f.is_directory)
        recur(f.to_s, regex) 
      end
    end
  end
end  

opts = Trollop::options do
  opt :perm, "Permission regular expression string (ex: finding all directories - '^d')", :type => String
  opt :adb, "Custom adb command", :default => "adb", :type => String
end

perm = opts[:perm]
AndroidTools.setAdb(opts[:adb])
  
raise Trollop::die("You must provide the permission regex") if perm.nil?

recur("/", perm)
