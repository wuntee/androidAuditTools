#!/usr/bin/env ruby

$:.push("../src/")

require 'androidtools'
require 'rubygems'
require 'trollop'
require 'colored'

@log = Logger.new(STDOUT)
@log.level = Logger::ERROR

opts = Trollop::options do
  opt :adb, "Custom adb command", :default => "adb", :type => String
  opt :debug, "Debug", :default => false
end

AndroidTools.setAdb(opts[:adb])
AndroidTools.setDebug(opts[:debug])
opts[:debug] and @log.level = Logger::DEBUG 

# See if we can find the su binary
ret = AndroidTools.runShell("echo $PATH")
ret.split(":").each do |dir|
  @log.debug("Searching for 'su': #{dir}")
  AndroidTools.findFile(dir, "su").each do |file|
    @log.debug("Found 'su': #{file.full_path}")
    puts("[-] The device is rooted".red.bold)
    exit
  end
end

# If we get here, the device is not rooted
puts("[-] The device is NOT rooted".green.bold)
