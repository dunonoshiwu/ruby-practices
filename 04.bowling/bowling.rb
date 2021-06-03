#!/usr/bin/env ruby

def calc_twice_score(point, twice_score, frame)
  if twice_score == 1 # twice_scoreが1の時
    point += frame[0]
    twice_score -= 1

  elsif twice_score == 2 # twice_scoreが2の時
    if frame[0] == 10
      point += frame[0]
      twice_score -= 1
    else # ストライク以外の場合（二投目もある）
      point += frame.sum
      twice_score -= 2
    end

  elsif frame[0] == 10 # twice_scoreが3以上ある
    point += frame[0] * 2 # 1個前と2個前のストライクの加算
    twice_score -= 2
  else # ストライク以外だった場合（二投目もある)
    point += frame.sum # 直前のストライクが1投目2投目を加算
    point += frame[0] # 2個前のストライクが1投目のスコアを加算
    twice_score -= 3
  end
  [point, twice_score]
end

# スコア取得して配列化
score = ARGV[0]
scores = score.split(',')
# ストライク（X）の2投目を擬似的に作る
shots = []
scores.each do |s|
  if s == 'X' && shots.size < 18 # 9フレーム目までに適用
    shots << 10
    shots << nil # ストライクの出たフレームの2投目に一時的にnil
  # 10フレーム目の処理。Xなら10を入れる。
  elsif s == 'X'
    shots << 10
  else
    shots << s.to_i
  end
end

# スコアを2分割してフレームを作る
frames = shots.each_slice(2).to_a

# nil要素を消す
frames.each(&:compact!)

# 10フレーム目で3投目まで投げてたら10フレーム目の配列に入れる
unless frames[10].nil?
  x = frames[10][0]
  frames.delete_at(10)
  frames[9] << x
end

point = 0
twice_score = 0 # ストライク・スペアの次の投球はスコア2倍で計算
# 1〜9フレームまでの足し算処理
frames[0..-2].each do |frame|
  # 直前でストライクやスペアがあった場合の追加ポイント加算
  point, twice_score = calc_twice_score(point, twice_score, frame) if twice_score.positive?

  # 通常のポイント加算
  if frame[0] == 10 # ストライクのとき
    point += 10
    twice_score += 2
  elsif frame.sum == 10
    point += 10
    twice_score += 1
  else
    point += frame.sum
  end
end

# 10フレームからの足し算処理
frames[9].each do |frame|
  # twice_scoreがまだある時の処理
  if twice_score.positive?
    point += frame
    twice_score -= 1
  end

  # 通常のポイント加算処理
  point += frame
end

p point
