module AndroidTools
  require 'androidfile'

  @ADB = "adb"
  @disclude = ["/proc", "/cache"]

  def AndroidTools.setAdb(s)
    @ADB = s
  end

  def AndroidTools.listDirectoryRecursive(dir, smart = true)
    ret = []
    AndroidTools.listDirectory(dir).each do |f|
      if(!f.name.nil?)
        if(smart)
          if(!@disclude.include?(f.full_path))
            ret.push(f)            
          end
        else
          ret.push(f)
        end
        if(f.is_directory)
          AndroidTools.listDirectoryRecursive(f.to_s).each do |tmp|
            ret.push(tmp)
          end 
        end
      end
    end
    return(ret)
  end
  
  def AndroidTools.listDirectory(dir)
    ret = []
    s = `#{@ADB} shell ls -l #{dir}`
    s.split("\r\n").each do |f|
      ret.push(AndroidFile.new(f, dir))
    end
    return(ret)
  end
  
  def AndroidTools.install(apk)
    s = `#{@ADB} install #{apk}`
    return(s)
  end
  
end

