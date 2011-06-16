$:.push("../src/")

require 'androidtools'
require 'androidadbline'
require 'rubygems'
require 'trollop'
require 'colored'

@log = Logger.new(STDOUT)
@log.level = Logger::ERROR

opts = Trollop::options do
  opt :color, "Print with NO color", :default => true
  opt :filter, "Only display certain debug messages, comman separated(debug,info,warn,error)", :type => String, :default => "debug,info,warn,error"
  opt :adb, "Custom adb command", :default => "adb", :type => String  
  opt :debug, "Debug", :default => false
end

color = opts[:color]
filter = opts[:filter].split(",")
AndroidTools.setDebug(opts[:debug])
opts[:debug] and @log.level = Logger::DEBUG
adb = opts[:adb]
  
@log.debug("Filter: #{filter}")
  
io = IO.popen("#{adb} logcat")
while(true)
  l = AndroidAdbLine.new(io.readline)
  @log.debug("Filter indexof[#{l.level}]?: #{filter.index(l.level)}")
  if(!filter.index(l.level).nil?)
    color ? puts(l.to_s_pretty) : puts(l.to_s)
  end
end
