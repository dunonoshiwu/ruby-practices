#!/usr/bin/env ruby

require 'date'
require 'optparse'

today = Date.today
params = ARGV.getopts("", "y:#{today.year}","m:#{today.month}")

# 引数なければ今日の日付が入ったオブジェクト使う
if params["y"] == nil
  day = today
else
  day = Date.new(params["y"].to_i, params["m"].to_i)
end
end_of_month = Date.new(day.year, day.month, -1)
first_of_month = Date.new(day.year, day.month, 1)
date = [*1..end_of_month.day] #今月の日付が入ってる配列

#日付の配列の１桁日付を２桁に調整
fix_date = date.map do |x|
  sprintf('%2d', x)
end

#西暦と月
print"　　　#{day.month}月 #{day.year}\n"
#曜日の表示
print"日 月 火 水 木 金 土\n"
#日付部分
day_of_the_week = first_of_month.wday
print "   " * day_of_the_week #ついたちが何曜日かでスペースの数調整した
fix_date.each do |x|
  new_day = Date.new(day.year, day.month, x.to_i)
  if new_day.saturday? #土曜日だったら改行
    print "#{x}\n"
  else
    print "#{x} "
  end
end
print "\n"
