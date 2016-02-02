# -*- coding: utf-8 -*-

#test for plotting and tweeting

#This program function
# check if the day changed by 10 minutes.
# if so, make the graph for the yesterday data
# and tweet it.

require 'twitter'
require 'gnuplot'
require 'fileutils'
require 'date'

CONSUMER_KEY        = "****"
CONSUMER_SECRET     = "****"
ACCESS_TOKEN        = "****"
ACCESS_TOKEN_SECRET = "****"

last_date = Date.today

while true do
  print "check"

  d = Date.today

  if last_date == d
    puts "day changed."
    
    path = last_date.strftime("./data/%Y/%m/")
    filename = last_date.strftime("./data/%Y/%m/%Y_%m_%d") + ".dat"
    outputname = last_date.strftime("./data/%Y/%m/%Y_%m_%d") + ".png"
    outputname2 =  last_date.strftime("./data/%Y/%m/%Y_%m_%d") + ".txt"

    count = []
    for num in 0..23 do
      count[num] = 0
    end

    File.open(filename, "r").each_line do |line|
      next unless line.split.length > 1
      next unless line.split[1][0,10] == last_date.strftime("%Y-%m-%d")
      day_time = line.split("\t")[1]
      time = day_time[11,8]
      hour = time[0,2].to_i
      count[hour] += 1
    end

    # to see as a data in letter
    File.open(outputname2, "w") do |f|
      f.puts count
    end

    # make graph
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|

        plot.title  last_date.strftime("%Y-%m-%d")       
        plot.xlabel 'time'
        plot.ylabel 'nom of tweets'
        plot.set "size ratio 1"
        plot.set 'terminal png size 1280,960'
        plot.xrange "[-0.5:23.5]"
        plot.yrange "[0:#{count.max*1.2}]"
        plot.set "output '#{outputname}'"
        plot.set "style fill solid"
        plot.set "boxwidth 0.5 relative"
        plot.set "xtics 1"
        
        x=[]
        y=[]

        for num in 0..23 do
          x << num
          y << count[num]
        end 
        
        plot.data << Gnuplot::DataSet.new([x,y]) do |ds|
          ds.with = "lines ls 1"
          ds.with = "boxes lc rgb 'light-green'"
          ds.linewidth = 4
          ds.notitle
        end
      end
    end 

    begin
      # Twitter.configure setting                                                      
      cli = Twitter::REST::Client.new do |config|
        config.consumer_key        = CONSUMER_KEY
        config.consumer_secret     = CONSUMER_SECRET
        config.access_token        = ACCESS_TOKEN
        config.access_token_secret = ACCESS_TOKEN_SECRET
      end

      # make tweet                                                                       
      str = "今日のタイムラインのツイート数はこんな感じでした"
      outputname = last_date.strftime("./data/%Y/%m/%Y_%m_%d") + ".png"

      # update tweet
      #cli.update_with_media(str, open(outputname))
    rescue => e
      STDERR.puts "[EXCEPTION] " + e.to_s
      exit 1
    end

    sleep(60 * 10)

  end
  
  last_date = d 
  sleep(1)
end
