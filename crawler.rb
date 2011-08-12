# -*- coding: utf-8 -*-

require 'rubygems'
require 'twitter_oauth'
require 'oauth'
require 'kconv'
require 'rubytter'
require 'yaml'

TOKEN = YAML.load_file("./token.yaml")

client = TwitterOAuth::Client.new(
  :consumer_key => TOKEN[:CONSUMER_KEY],
  :consumer_secret => TOKEN[:CONSUMER_SECRET],
  :token => TOKEN[:ACCESS_TOKEN],
  :secret => TOKEN[:ACCESS_TOKEN_SECRET]
)



clnt = Rubytter.new
clnt.search("Vim OR Emacs -RT", :lang => "ja").each do |status|
	puts "#{status.user.screen_name}: #{status.text}"
end

SCREEN_NAME = 'tweet-war bot'
MSG = 'Vim'

words = [
  "いいよ！！",
  "は正義"
]

dm = client.messages
since_id = 1
dm.each do |key,value|
  if key['text'] =~ /^\d+$/
    since_id = key['text'].to_i
    break
  end
end

timeline = client.home_timeline( :count => 200, :since_id => since_id )

timeline.each do |tl| 
  msg = Kconv.toutf8( MSG )
  text = tl["text"]
  id = tl["id"].to_i
  since_id = id if id > since_id
  if text =~ /#{msg}/u 
    user = tl["user"]["screen_name"]
    if user == SCREEN_NAME || (text =~ /@/ && !(text =~ /#{SCREEN_NAME}/))
      next
    end

    text_end = Kconv.toutf8( words[ rand( words.size ) ] )
    mention_m = "@#{user} #{msg} #{text_end}"
    puts mention_m
    #client.update(mention_m, :in_reply_to_status_id => id)
    sleep 1
  end
end

client.message( SCREEN_NAME, since_id )
