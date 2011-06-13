#!/usr/bin/env ruby

$:.push("../src/")

require 'androidtools'
require 'rubygems'
require 'trollop'
require 'colored'

@log = Logger.new(STDOUT)
@log.level = Logger::ERROR

opts = Trollop::options do
  opt :cerFile, "cer file to install", :type => String, :required => true
  opt :tmpFile, "Temporary cert file", :default => "/tmp/cacerts", :type => String
  opt :storePass, "Default Android cacerts store pass (typaicall 'changeit', but sometimes blank '')", :default => "changeit", :type => String
  opt :aliasName, "Alias name for the added cert", :default => "AndroidAuditTools-cert", :type => String
  opt :adb, "Custom adb command", :default => "adb", :type => String  
  opt :debug, "Debug", :default => false
end

AndroidTools.setAdb(opts[:adb])
AndroidTools.setDebug(opts[:debug])
opts[:debug] and @log.level = Logger::DEBUG
cerFile = opts[:cerFile]
storePass = opts[:storePass]
aliasName = opts[:aliasName]
tmpFile = opts[:tmpFile]
  
begin
  AndroidTools.installCer(cerFile, tmpFile, storePass, aliasName)
  puts("#{cerFile} was successfully added to the device.".green)
rescue Exception => e
  puts("There was a problem installing the cert: #{e}".red.bold)
end
 
