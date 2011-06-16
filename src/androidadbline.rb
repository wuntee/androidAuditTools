class AndroidAdbLine
# W/RequestProcessingService(  231): RPS schedule next update run for 2011-06-16T08:08:58.000-04:00
  require 'colored'
  
  attr_accessor :raw, :level, :c, :line, :message
  
  DEBUG = "debug"
  INFO  = "info"
  WARN  = "warn"
  ERROR = "error"
  
  def initialize(s)
    @raw = s
    
    # Level
    level = s[0]
    if(level == 'D') 
      @level = DEBUG
    elsif(level == 'I')
      @level = INFO
    elsif(level == 'W')
      @level = WARN
    elsif(level == 'E')
      @level = ERROR
    end
    
    # Class
    @c = s[2..-1].split("(")[0]
    
    # Line
    @line = s[s.index("(")+1..s.index(")")-1].strip
    
    # Message
    @message = s[s.index(":")+1..-1].rstrip
  end
  
  def to_s()
    return("%-5s: %-15s[%5s]: %s" % [@level, @c, @line, @message])
  end
  
  def to_s_pretty()
    if(@level == DEBUG)
      return("%-5s: %-15s[%5s]: %s" % [@level, @c, @line, @message])
    elsif(@level == INFO)
      return("%-5s: %-15s[%5s]: %s".blue % [@level, @c, @line, @message])
    elsif(@level == WARN)
      return("%-5s: %-15s[%5s]: %s".yellow % [@level, @c, @line, @message])
    elsif(@level == ERROR)
      return("%-5s: %-15s[%5s]: %s".red % [@level, @c, @line, @message])
    end
  end
end