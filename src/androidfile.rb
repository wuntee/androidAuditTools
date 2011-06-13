class AndroidFile
  attr_reader :full_path, :perm, :user, :group, :size, :modified, :name, :link, :is_link, :is_file, :is_directory

  def initialize(s, root)
    sSplit = s.split
    @perm = sSplit[0]
    @user = sSplit[1]
    @group = sSplit[2]
    if(@perm.start_with?("-"))
      @is_file = true
      @size = sSplit[3].strip
      @modified = "%s %s" % [sSplit[4].strip, sSplit[5].strip]
      @name = sSplit[6].strip
    elsif(@perm.start_with?("d"))
      @is_directory = true
      @modified = "%s %s" % [sSplit[3].strip, sSplit[4].strip]
      @name = sSplit[5].strip
    elsif(@perm.start_with?("l"))
      @is_link = true
      @modified = "%s %s" % [sSplit[3].strip, sSplit[4].strip]
      @name = sSplit[5].strip
      @link = sSplit[7].strip
    elsif(@perm.start_with?("c"))
      @size = "%s %s" % [sSplit[3].strip, sSplit[4].strip]
      @modified = "%s %s" % [sSplit[5].strip, sSplit[6].strip]
      @name = sSplit[7].strip
    end
    
    if(root.end_with?("/"))
      @full_path = "%s%s" % [root, @name]
    else
      @full_path = "%s/%s" % [root, @name]
    end
    
    if(@is_directory && !@full_path.end_with?("/"))
      @full_path = "#{@full_path}/"
    end
  end
  
  def to_s
    return(@full_path)
  end
  
  def to_s_full
    return("%s %-15s %-15s %-10s %-15s %s" % [@perm, @user, @group, @size, @modified, @full_path])
  end
  
end