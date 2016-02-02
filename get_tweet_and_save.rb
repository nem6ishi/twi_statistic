# -*- coding: utf-8 -*-

#This program function
# get tweet from userstream
# save the tweet

require 'tweetstream'
require 'fileutils'
require 'date'


CONSUMER_KEY        = "****"
CONSUMER_SECRET     = "****"
ACCESS_TOKEN        = "****"
ACCESS_TOKEN_SECRET = "****"

TweetStream.configure do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_TOKEN_SECRET
  config.auth_method        = :oauth
end
client_stream = TweetStream::Client.new

puts "start"
client_stream.userstream do |status|
  puts "stream"

  user_id = status.user.id
  name = status.user.name
  tweet_id = status.id
  screen_name = status.user.screen_name
  text = status.text
  time_global = DateTime.parse(status.created_at.to_s)
  time = time_global.new_offset(Rational(3,8))

  puts name + text
  puts "\n"

  record = name + "\t" + screen_name + "\t" + text + "\n" 
  d = Date.today
  path = d.strftime("./data/%Y/%m/")
  FileUtils.mkdir_p(path) unless FileTest.exist?(path)
  filename = d.strftime("./data/%Y/%m/%Y_%m_%d") + ".dat"

  #id time tweet_id name screen_name @id text
  File.open(filename, "a") do |f|
    f.print user_id
    f.print "\t"
    f.print time
    f.print "\t"
    f.print tweet_id
    f.print "\t"
    f.print record
  end 
    
end
