module AndroidTools
  require 'androidfile'
  require 'logger'

  @log = Logger.new(STDOUT)
  @log.level = Logger::ERROR

  @ADB = "adb"
  @KEYTOOL = "keytool"
  DISCLUDE = ["/dev/", "/acct/uid/", "/proc/", "/cache/", "/sys/"]
  ANDROID_CERT_FILE = "/system/etc/security/cacerts.bks"

  def AndroidTools.setAdb(s)
    @ADB = s
  end
  
  def AndroidTools.setDebug(b)
    if(b) 
      @log.level = Logger::DEBUG
    else
      @log.level = Logger::ERROR
    end
  end
 
  # TODO 
  def AndroidTools.getPackageNameFromApk(apk)
    # Unzip .apk file
    # dBase3 read manifest file
  end

  def AndroidTools.listDirectoryRecursive(dir, smart = true)
    ret = []
    AndroidTools.listDirectory(dir).each do |f|
      if(smart && !AndroidTools::DISCLUDE.include?(f.full_path) || !smart)
        @log.debug("adding: #{f.full_path}")
        ret.push(f)
        if(f.is_directory)
          AndroidTools.listDirectoryRecursive(f.full_path,smart).each do |x|
            if(smart && !AndroidTools::DISCLUDE.include?(x.full_path) || !smart)
              ret.push(x)
            end
          end
        end
      end
    end
    return(ret)
  end
  
  def AndroidTools.installCer(cerFile, tmpFile = "/tmp/cacerts.bks", storePass="changeit", aliasName="AndroidAuditTools-cert")
    @log.debug("Pulling cert file")
    AndroidTools.pullCertFile(tmpFile)
    #keytool -keystore cacerts.bks -storetype BKS -provider org.bouncycastle.jce.provider.BouncyCastleProvider -storepass changeit -importcert -trustcacerts -alias MALLORY -file ca.cer -noprompt
    @log.debug("Adding #{cerFile} to cert file")
    c = "#{@KEYTOOL} -keystore #{tmpFile} -storetype BKS -provider org.bouncycastle.jce.provider.BouncyCastleProvider -storepass #{storePass} -importcert -trustcacerts -alias #{aliasName} -file #{cerFile} -noprompt"
    @log.debug("Running: #{c}")
    c = `#{c}`.strip
    @log.debug("Returned: #{c}")
    AndroidTools.checkKeytoolError(c)
    @log.debug("Mounting /system as read/write")
    AndroidTools.remountSystemRw()
    @log.debug("Changing file permissions")
    AndroidTools.runShell("chmod 777 #{ANDROID_CERT_FILE}")
    @log.debug("Overriting file")
    AndroidTools.pushFile(tmpFile, ANDROID_CERT_FILE)
    @log.debug("Removing temporary file")
    File.delete(tmpFile)
    @log.debug("Changing file permissions back")
    AndroidTools.runShell("chmod 644 #{ANDROID_CERT_FILE}")
  end
  
  def AndroidTools.pullCertFile(destination)
    AndroidTools.pullFile(ANDROID_CERT_FILE, destination)
  end
  
  def AndroidTools.remountSystemRw()
    AndroidTools.runShell("mount -o remount,rw /dev/block/mtdblock0 /system")
  end
  
  def AndroidTools.pullFile(source, destination)
    return(AndroidTools.runAdbCommand(" pull #{source} #{destination}"))
  end
  
  def AndroidTools.pushFile(source, destination)
    return(AndroidTools.runAdbCommand(" push #{source} #{destination}"))
  end
  
  def AndroidTools.listDirectory(dir)
    dir = dir.strip
    ret = []
    s = AndroidTools.runShell("ls -l #{dir}")
    s.split("\r\n").each do |f|
      ret.push(AndroidFile.new(f, dir))
    end
    return(ret)
  end
  
  def AndroidTools.install(apk)
    return(AndroidTools.runAdbCommand(" install #{apk}"))
  end
  
  def AndroidTools.runShell(command)
    return(AndroidTools.runAdbCommand("shell '#{command}'"))
  end
  
  def AndroidTools.findFile(rootDir, filename, smart = true)
    ret = []
    AndroidTools.listDirectory(rootDir).each do |f|
      if(!f.name.nil?)
        if(smart)
          if(!DISCLUDE.include?(f.full_path) && f.name == filename)
            ret.push(f)            
          end
        else
          if(f.name == filename)
            ret.push(f)
          end
        end
        if(f.is_directory)
          AndroidTools.listDirectoryRecursive(f.to_s).each do |tmp|
            if(tmp.name == filename)
              ret.push(tmp)
            end
          end 
        end
      end
    end
    return(ret)    
  end
  
  private
  def AndroidTools.runAdbCommand(command)
    c = "#{@ADB} #{command}"
    @log.debug("Running: #{c}")
    c = `#{c}`.strip
    @log.debug("Returned: #{c}")
    AndroidTools.checkAdbError(c)
    return(c)
  end
  
  def AndroidTools.checkAdbError(commandOutput)
    # error: device not found
    # error: more than one device and emulator (STDERR)
    if(commandOutput =~ /^error/i)
      raise("Command returned error: '#{commandOutput}")
    end
  end
  
  def AndroidTools.checkKeytoolError(commandOutput)
    # keytool error: java.lang.Exception: Certificate not imported, alias <AndroidAuditTools-cert> already exists
    if(commandOutput =~ /^keytool error/i)
      raise("Command returned error: '#{commandOutput}")
    end
  end
  
end

