#!/usr/bin/env ruby
require 'cgi'

ID_PAIR = ["0","1"]

def main()
  begin 
    cgi = CGI.new
    
    action = cgi['action']
    mode = cgi['mode']

    if action == "" or action == nil or
       mode == "" or mode == nil
      print_error
    
    #mode=match or write
    elsif(mode == "match")
      result = match_state(action)
      print "Content-type: text/html\r\n\r\n"
      print result
    else
      id = cgi['id']
      state = cgi['state']
      
      if id  == nil or id == "" or
         state == nil or state == "" or
         !ID_PAIR.include?(id)
         print_error
      else
        time = Time.now
        writedata(id,action,state,time)
        #openfile(id,action,state)
        print "Content-type: text/html\r\n\r\n"
        print "OK"
     end
    end
  rescue
    print_error
  end
  #openfile(id,action,state)

end

def print_error
    print "Content-type: text/html\r\n\r\n"
    print "ERROR"
end

def writedata(id,action,state,time)
  filename = "log/#{action}_log_#{id}.txt"
  statefile ="log/#{action}_state_#{id}.txt"

  time_str =  time.strftime("%Y/%m/%d %H:%M:%S")  
  sfp = open(statefile, "w")
  sfp.print time_str,"\t"
  sfp.print state
  sfp.close
 
  fp = open(filename, "a")
  fp.print time_str,"\t"
  fp.print id,"\t"
  fp.print action,"\t"
  fp.print state,"\n"
  fp.close
end

#def openfile(id,action,state)
def match_state(action)

  f = open("log/#{action}_state_#{ID_PAIR[0]}.txt")
  line = f.gets
  p_state = line.split("\t")[1].to_i if(line != nil )
  f.close

  f = open("log/#{action}_state_#{ID_PAIR[1]}.txt")
  line = f.gets
  p_state2 = line.split("\t")[1].to_i if(line != nil )
  f.close

  if(p_state != nil && p_state2 != nil &&
     p_state == p_state2 && p_state != 0 && p_state2 != 0)
   if (p_state == p_state2)
     return "1"  
   else
     return "0"
   end
  else
    return "0"
  end
end

main
