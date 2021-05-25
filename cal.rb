#!/usr/bin/env ruby

require 'date'
require 'optparse'

today = Date.today
params = ARGV.getopts("", "y:#{today.year}","m:#{today.month}")
#p params

# 引数なければ今日の日付が入ったオブジェクト使う
if params["y"] == nil
  a = today
else
  a = Date.new(params["y"].to_i, params["m"].to_i)
end
end_of_month = Date.new(a.year, a.month, -1)
first_of_month = Date.new(a.year, a.month, 1)
array = [*1..end_of_month.day]
#日付の配列の１桁日付にスペースで幅増やしてる
array2 = array.map { |x|
  if x < 10
    " #{x}"
  else
    x
  end
}
#西暦と月
print"　　　#{a.month}月 #{a.year}\n"
#曜日の表示
print"日 月 火 水 木 金 土\n"
#日付部分
day_of_the_week = first_of_month.wday
print "   " * day_of_the_week#ついたちが何曜日かでスペースの数調整した
array2.each do |day|
  new_day = Date.new(a.year, a.month, day.to_i)
  if new_day.saturday? #土曜日だったら改行
    print "#{day}\n"
  else
    print "#{day} "
  end
end
print "\n"
