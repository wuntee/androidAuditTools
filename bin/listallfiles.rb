#!/usr/bin/env ruby

$:.push("../src/")

require 'androidtools'
require 'rubygems'
require 'trollop'

@disclude = ["/proc", "/cache"]

def recur(dir, smart)
  AndroidTools.listDirectory(dir).each do |f|
    if(!f.name.nil?)
      if(smart)
        if(!@disclude.include?(f.full_path))
          puts(f)
        end
      else
        puts(f)
      end
      if(f.is_directory)
        recur(f.to_s, smart) 
      end
    end
  end
end  

opts = Trollop::options do
  opt :smart, "Disclue directories that change regularly.", :default => true
  opt :start, "Starting directory", :type => String, :default => "/"
  opt :adb, "Custom adb command", :default => "adb", :type => String
end

smart = opts[:smart]
start_dir = opts[:start]
AndroidTools.setAdb(opts[:adb])
  
recur(start_dir, smart)