require "socket"

class SyncTrash


  def initialize(ip="127.0.0.1", port=4321)
    @socket = TCPSocket.new(ip, port) 
    load_default
    load
    p "id:#{@id}"
    Thread.new{ remote_loop }
  
    while line = @socket.gets
      level = parse(line.chomp) 
      if(level != nil)
        set_servo(level)
      end
    end
    @socket.close
  end

  def load_default()
    @id = "1"
    @url_write = "http://tsujita.org/syncdecor/trashwrite1.php"
    @url_read = "http://tsujita.org/syncdecor/trashstate1.txt"
    @servo_open = "Phidgets,Out,Servo,0,0,80\r\n"
    @servo_close = "Phidgets,Out,Servo,0,0,170\r\n" 
  end
    
  def load (file = "setting.txt")
    return if !File.exist? file
    File.open(file) do |f|
      @id = f.gets.chomp
      @url_write = f.gets.chomp
      @url_read = f.gets.chomp
      @servo_open = unescape(f.gets.chomp)
      @servo_close = unescape(f.gets.chomp)
      
      p @url_write
      p @url_read
      p @servo_open
      p @servo_close
    end
  end
  
  def unescape (str)
    str.gsub!(/\\r/, "\r")
    str.gsub!(/\\n/, "\n")
    str.gsub!(/\\0/, "\0")
    str
  end
  
  



  def remote_loop(sleep_time = 1)
    level_pre = 0
    begin
      while(true)
        level = open_url
        if(level != nil && level != level_pre)
          set_servo2(level)
          level_pre = level
        end
        sleep(sleep_time)
      end
    rescue
      puts($!)
    end
  end


  def parse(line)
    args = line.split(",")
    if args[0] =="Phidgets" and
      args[1] == "In" and
      args[2] == "InterfaceKit" and
      #args[3] == "27249" and
      args[4] == "Digital"
      case args[5]
        when "0"
          level = args[6].to_i
      end
    end
    level
  end

  #ServoMotorÇÃêßå‰
  def set_servo(level)
    if(level==0)
      url = @url_write + "?state=0&id=#{@id}"
      open(url) 
      p level.to_s + " " + url
      @socket.print @servo_close
    elsif(level==1)
      url = @url_write + "?state=1&id=#{@id}"
      open(url)
      p level.to_s + " " + url
      @socket.print @servo_open
    end
  end

  def set_servo2(level)
    if(level==0)
      @socket.print @servo_close
    elsif(level==1) 
      @socket.print @servo_open
    end  
    #@socket.print str
  end

  def open_url #(sleep_time = 10)
    #ÉtÉ@ÉCÉãÇÃì«Ç›çûÇ›
    begin
      require "open-uri"
      level = nil
      f = open(@url_read)
      while line = f.gets
        level = line.chomp.to_i
        puts line if(line != nil)
      end
      f.close
      level
    rescue
      nil
    end
    #sleep(sleep_time)
  end
end


SyncTrash.new
