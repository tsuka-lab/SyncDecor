#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'cgi'
require 'date'

ID_PAIR = ["0","1"]

def main()
  begin
    cgi = CGI.new #Webブラウザからリクエストを受け取るたび、プログラム実行、結果を送り返す

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
        #time.utc
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
  logfile = "log/#{action}_log_#{id}.txt" #全部記録
  statefile ="log/#{action}_state_#{id}.txt" #上書き保存

  time_str =  time.strftime("%Y/%m/%d %H:%M:%S") #時刻を文字列に変換するex)2006/12/21 06:08:13
  sfp = open(statefile, "w")
  sfp.print time_str,"\t" #statefileに時刻を書き込み
  sfp.print state
  sfp.close

  fp = open(logfile, "a")
  fp.print time_str,"\t" #\tはタブ
  fp.print id,"\t"
  fp.print action,"\t"
  fp.print state,"\n"
  fp.close
end

#def openfile(id,action,state)
def match_state(action)
 # f = open("log/#{action}_state_#{ID_PAIR[0]}.txt") #ファイルを開く
 # line = f.gets #ファイルを処理
 # p_state = line.split("\t")[1].to_i #spilit:最後の/を区切りに２つの値に分割 to_i:オブジェクトを整数に変換
 # if(line != nil ) #nilが返ってきたら閉じる
 # f.close

 # f = open("log/#{action}_state_#{ID_PAIR[1]}.txt")
 # line = f.gets
 # p_state2 = line.split("\t")[1].to_i if(line != nil )
 # f.close

 # if(p_state != nil && p_state2 != nil &&
 #    p_state == p_state2 && p_state != 0 && p_state2 != 0)
 #   if (p_state == p_state2)
 #     return "1"
 #   else
 #     return "0"
 #   end
 # else
 #   return "0"
 # end

  f = open("log/#{action}_log_#{ID_PAIR[0]}.txt")
  time_str = f.time_str
  if(time_str != nil)
  f.close

  f = open("log/#{action}_log_#{ID_PAIR[1]}.txt")
  time_str2 = f.time_str
  if(time_str2 != nil)
  f.close

  time_str3 = time_str + (60*60*6)

  if(time_str2 != nil && time_str3 != nil &&
     time_str2 == time_str3 && time_str2 != 0 && time_str3 != 0)
    if(time_str2 == time_str3)
      return "1"
    else
      return "0"
    end
    else
      return "0"
    end

end

main
