#!/usr/bin/env ruby

#スコア取得して配列化
score = ARGV[0]
scores = score.split(',')
#ストライク（X）の2投目を擬似的に作る
shots = []
scores.each do |s|
  if s == 'X' && shots.size < 18 #9フレーム目までに適用
    shots << '10'
    shots << 'buf' #ストライクの出たフレームの2投目に一時的な変数
  else
    #10フレーム目の処理。Xなら10を入れる。
    if s == 'X' 
      shots << '10'
    else
      shots << s
    end
  end
end

#スコアを2分割してフレームを作る
frames = []
shots.each_slice(2) do |s|
  frames << s
end

#"buf"要素を消す
frames.each do |frame|
  frame.delete("buf")
end

#10フレーム目で3投目まで投げてたら10フレーム目の配列に入れる
unless frames[10].nil?
  x = frames[10][0]
  frames.delete_at(10)
  frames[9] << x
end

point = 0
double_bonus = 0
index = 1
#1〜9フレームまでの足し算処理
frames[0..-2].each do |frame|
  #直前でストライクやスペアがあった場合の追加ポイント加算
  if double_bonus > 0
    if double_bonus == 1 #double_bonusが1の時
      point += frame[0].to_i
      double_bonus -= 1

    elsif double_bonus == 2 #double_bonusが2の時
      if frame[0] == "10"
        point += frame[0].to_i
        double_bonus -= 1
      else #ストライク以外だった場合（二投目もある）
        point += frame[0].to_i + frame[1].to_i
        double_bonus -= 2
      end

    else #double_bonusが3以上ある
      if frame[0] == "10" 
        #double_bonusが2個以上でストライクの場合は
        #1個前と2個前のストライクの加算を行うため2倍
        point += frame[0].to_i * 2
        double_bonus -= 2
      else #ストライク以外だった場合（二投目もある）
        #これは直前と2個前にストライクがあるパターン
        point += frame[0].to_i + frame[1].to_i #直前のストライクが1投目2投目を加算
        point += frame[0].to_i #2個前のストライクが1投目のスコアを加算
        double_bonus -= 3
      end
    end
  end

  #通常のポイント加算
  if frame[0] == "10" #ストライクのとき
    point += 10
    double_bonus += 2
  elsif frame[0].to_i + frame[1].to_i == 10 #スペアのとき
    point += 10
    double_bonus += 1
  else
    point += frame[0].to_i + frame[1].to_i
  end
#p "index: #{index}, point: #{point}, bonus: #{double_bonus}"
#index += 1
end
#p "point: #{point}"

#10フレームからの足し算処理
frames[9].each do |frame|
  #double_bonusがまだある時の処理
  if double_bonus > 0
    point += frame.to_i
    double_bonus -= 1
  end

  #通常のポイント加算処理
  point += frame.to_i
end

p point
