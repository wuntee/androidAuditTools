#!/usr/bin/env ruby

$:.push("../src/")

require 'androidtools'
require 'rubygems'
require 'trollop'
require 'colored'

class TwoFiles
  attr_reader :filea, :fileb
  
  def initialize(a, b)
    @filea = a
    @fileb = b
  end
end

@added = []
@deleted = []
@modified = []
def fileDiff(old, new)
  # Find all files that have been added
  new.each do |newfile|
    found = false
    old.each do |oldfile|
      if(newfile.full_path == oldfile.full_path)
        found = true
        # Something has changed in the file
        if(newfile.modified != oldfile.modified)
          f = TwoFiles.new(oldfile, newfile)
          @log.debug("Modified: #{f}")
          @modified.push(f)
        end
        
      end      
    end
    # If we get to here, the file was added
    if(found == false)
      f = TwoFiles.new(nil, newfile)
      @log.debug("Added: #{f}")
      @added.push(f)
    end
  end
  
  # Find all files that have been deleted
  old.each do |oldfile|
    found = false
    new.each do |newfile|
      if(oldfile.full_path == newfile.full_path)
        found = true
      end
    end
    if(found == false)
      f = TwoFiles.new(oldfile, nil)
      @log.debug("Deleted: #{f}")
      @deleted.push(f)
    end
  end
  
end

@log = Logger.new(STDOUT)
@log.level = Logger::ERROR

opts = Trollop::options do
  opt :apk, "APK File to install", :type => String
  opt :pause, "Pause after the first scan", :default => false
  opt :adb, "Custom adb command", :default => "adb", :type => String
  opt :debug, "Debug", :default => false
end

apk = opts[:apk]
apk.nil? ? pause = true : pause = opts[:pause]
AndroidTools.setAdb(opts[:adb])
opts[:debug] and @log.level = Logger::DEBUG
opts[:debug] and AndroidTools.setDebug(true) 

start_dir = "/"

puts("Scanning device prior to install")
first = AndroidTools.listDirectoryRecursive(start_dir)

if(!apk.nil?)
  puts("Installing #{apk}")
  ret = AndroidTools.install(apk)
  puts("    #{ret}")
end

if(pause)
  puts("Paused. Press Enter when you would like to continue...")
  gets()
end

puts("Scanning device post install")
second = AndroidTools.listDirectoryRecursive(start_dir)
  
puts("Differences:")
fileDiff(first, second)
@added.each do |f|
  first = f.filea
  second = f.fileb
  puts("[+] #{second}".green)
  puts("    perms : #{second.perm} #{second.user} #{second.group} #{second.size} #{second.modified}")
end
@deleted.each do |f|
  first = f.filea
  second = f.fileb
  puts("[-] #{first}".red)
end
@modified.each do |f|
  first = f.filea
  second = f.fileb
  puts("[c] #{first}".blue)
  puts("    before: #{first.perm} #{first.user} #{first.group} #{first.size} #{first.modified}")
  puts("    after : #{second.perm} #{second.user} #{second.group} #{second.size} #{second.modified}")
end