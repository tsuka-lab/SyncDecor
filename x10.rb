require "socket"

class X10


  def initialize(ip="127.0.0.1", port=4322)
    @socket = TCPSocket.new(ip, port) 
    load_default
    load
    p "id:#{@id}"
    Thread.new{ remote_loop }
    Thread.new{ remote_loop_aroma }
  
    while line = @socket.gets
      #p line
      level = parse(line.chomp) 
      if(level != nil)
        set_lamp(level)
      #つぎのループ
        next
      end
      
      level_aroma = parse_aroma(line.chomp) 
      if(level_aroma != nil)
        set_aroma(level_aroma)
      end
    end
    
    @socket.close
  end

  def load_default()
    @id = "1"
    @url_write = "http://133.65.195.83/~hitomi/syncdecor/lampwrite1.php"
    @url_read = "http://133.65.195.83/~hitomi/syncdecor/lampstate1.txt"
    @url_write_aroma = "http://133.65.195.83/~hitomi/syncdecor/aromawrite1.php"
    @url_read_aroma = "http://133.65.195.83/~hitomi/syncdecor/aromastate1.txt"
    @lamp_on = "X10,Out,A,1,Power,True\r\n"
    @lamp_off = "X10,Out,A,1,Power,False\r\n" 
    @aroma_on = "X10,Out,A,2,Power,True\r\n"
    @aroma_off = "X10,Out,A,2,Power,False\r\n" 
    
  end
    
  def load (file = "setting_x10.txt")
    return if !File.exist? file
    File.open(file) do |f|
      @id = f.gets.chomp
      @url_write = f.gets.chomp
      @url_read = f.gets.chomp
      @url_write_aroma = f.gets.chomp
      @url_read_aroma = f.gets.chomp
      @lamp_on = unescape(f.gets.chomp)
      @lamp_off = unescape(f.gets.chomp)
      @aroma_on = unescape(f.gets.chomp)
      @aroma_off = unescape(f.gets.chomp)
      
      
      p @url_write
      p @url_read
      p @url_write_aroma
      p @url_read_aroma
      p @lamp_on
      p @lamp_off
      p @aroma_on
      p @aroma_off
      
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
        level = open_file
        if(level != nil && level != level_pre)
          set_lamp2(level)
          level_pre = level
        end
        sleep(sleep_time)
      end
    rescue
      puts($!)
    end
  end
  
  
   def remote_loop_aroma(sleep_time = 1)
    level_aroma_pre = 0
    begin
      while(true)
        level_aroma = open_file_aroma
        if(level_aroma != nil && level_aroma != level_aroma_pre)
          set_aroma2(level_aroma)
          level_aroma_pre = level_aroma
        end
        sleep(sleep_time)
      end
    rescue
      puts($!)
    end
  end


  def parse(line)
  
    args = line.split(",")
    if args[0] =="X10" and
      args[1] == "In" and
      args[2] == "A" and
      args[3] == "1" and
      args[4] == "Power"
          case args[5]
            when "True"
              level = 1
          
            else 
              level = 0
             
          end
    end
    level
  end
  
  
  def parse_aroma(line)
    args = line.split(",")
    if args[0] =="X10" and
      args[1] == "In" and
      args[2] == "A" and
      args[3] == "2" and
      args[4] == "Power"
          case args[5]
            when "True"
              level_aroma = 1
            else 
              level_aroma = 0
          end
    end
    level_aroma
  end
  

  #Lampの制御
  def set_lamp(level)
  #LampOff
    if(level==0)
      url = @url_write + "?state=0&id=#{@id}"
      open(url) 
      p level.to_s + " " + url
      @socket.print @lamp_off
      #LampOn
    elsif(level==1)
      url = @url_write + "?state=1&id=#{@id}"
      open(url)
      p level.to_s + " " + url
      @socket.print @lamp_on
    end
  end

  def set_lamp2(level)
    if(level==0)
      @socket.print @lamp_off
    elsif(level==1) 
      @socket.print @lamp_on
    end  
    #@socket.print str
  end
  
  
  
  
   #Aromaの制御
  def set_aroma(level_aroma)
  #AromaOff
    if(level_aroma==0)
      url = @url_write_aroma + "?state=0&id=#{@id}"
      open(url) 
      p level_aroma.to_s + " " + url
      @socket.print @aroma_off
      
  #AromaOn
    elsif(level_aroma==1)
      url = @url_write_aroma + "?state=1&id=#{@id}"
      open(url)
      p level_aroma.to_s + " " + url
      @socket.print @aroma_on
    end
  end

  def set_aroma2(level_aroma)
    if(level_aroma==0)
      @socket.print @aroma_off
    elsif(level_aroma==1) 
      @socket.print @aroma_on
    end  
    #@socket.print str
  end
  
  
  
  

  def open_file #(sleep_time = 10)
    #ファイルの読み込み
    require "open-uri"
    level = nil
    f = open(@url_read)
    while line = f.gets
      level = line.chomp.to_i
      puts line if(line != nil)
    end
    f.close
    level
    #sleep(sleep_time)
  end



 def open_file_aroma #(sleep_time = 10)
    #ファイルの読み込み
    require "open-uri"
    level_aroma = nil
    f = open(@url_read_aroma)
    while line = f.gets
      level_aroma = line.chomp.to_i
      puts line if(line != nil)
    end
    f.close
    level_aroma
    #sleep(sleep_time)
  end

end


X10.new
