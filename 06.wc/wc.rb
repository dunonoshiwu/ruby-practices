#!/usr/bin/env ruby
require 'optparse'

def main
  options = ARGV.getopts('l')
  args = ARGV # 引数のファイル名
  file_info = if args.any? # 引数にファイル名があれば
                search_file_info(args)
              elsif File.pipe?($stdin) # パイプで標準入力があれば
                search_stdin_info
              else # 引数も標準入力もなければ終了
                exit
              end
  if options['l']
    output_l_option(file_info) # -l オプション付きの出力
  else
    output_no_option(file_info) # オプション無しの普通の出力
  end
end

# ファイル情報を取得するメソッド １つのファイル１つのハッシュで返す
def search_file_info(args)
  if args.size == 1
    search_single_file_info(args[0]) # ファイル名が１つのとき, 配列じゃなくて文字列を渡す
  else
    search_multi_file_info(args) # ファイル名が２つ以上のとき
  end
end

def search_single_file_info(args)
  file = args
  file_info = {}
  words_count = 0
  bytes_count = 0
  File.open(file, 'r') do |f|
    f.each_line do |line|
      bytes_count += line.to_s.bytesize # 各行のバイト数を加算
      line.chomp!
      words = line.split(/\s+/) # それぞれの行で空白で区切って配列化
      words_count += words.size # 単語数を加算
    end
    file_info[:lines] = f.lineno # IO#lineno 行数を返す
    file_info[:words] = words_count
    file_info[:bytes] = bytes_count
    file_info[:name] = File.basename(file)
    file_info
  end
end

# 複数のハッシュを配列に入れて返す
def search_multi_file_info(args)
  file_info = []
  args.each do |arg|
    file_info << search_single_file_info(arg)
  end
  file_info
end

# 標準入力から行数・単語数・バイト数をハッシュにして返す
def search_stdin_info
  file_info = {}
  words_count = 0
  lines_count = 0
  bytes_count = 0
  ARGF.each do |line| # 標準入力のすべての行を取得
    lines_count += 1
    bytes_count += line.to_s.bytesize
    line.chomp!
    words = line.split(/\s+/) # それぞれの行で空白で区切って配列化
    words_count += words.size # 単語数を加算
  end
  file_info[:lines] = lines_count
  file_info[:words] = words_count
  file_info[:bytes] = bytes_count
  file_info
end

# ファイル情報を出力するメソッド
def output_l_option(file_info)
  if file_info.instance_of?(Array) # 配列だったら（ファイル情報が複数だったら）
    output_multi_line_l_option(file_info) # ファイル名が１つのとき
  else
    max_width = calc_max_width(file_info)
    output_single_line_l_option(file_info, max_width) # ファイル名が２つ以上のとき
  end
end

def output_no_option(file_info)
  if file_info.instance_of?(Array) # 配列だったら（ファイル情報が複数だったら）
    output_multi_line(file_info) # ファイル名が１つのとき
  else
    max_width = calc_max_width(file_info)
    output_single_line(file_info, max_width) # ファイル名が２つ以上のとき
  end
end

# １行の出力
def output_single_line(file_hash, max_width)
  print file_hash[:lines].to_s.rjust(max_width, ' ')
  print file_hash[:words].to_s.rjust(max_width, ' ')
  print file_hash[:bytes].to_s.rjust(max_width, ' ')
  # ハッシュにnameキーがあれば出力。標準出力にはない。
  print " #{file_hash[:name].ljust(max_width, ' ')}" if file_hash.key?(:name)
  puts
end

def output_multi_line(files)
  total = { lines: 0, words: 0, bytes: 0, name: 'total' }
  max_width = 0
  max_width = calc_max_width_files(files)
  # ファイルごとにファイル情報を出力
  files.each do |file_hash|
    total[:lines] += file_hash[:lines].to_i
    total[:words] += file_hash[:words].to_i
    total[:bytes] += file_hash[:bytes].to_i
    output_single_line(file_hash, max_width)
  end
  output_single_line(total, max_width) # 最後にtotal出力
end

def output_single_line_l_option(file_hash, max_width)
  print file_hash[:lines].to_s.rjust(max_width, ' ')
  # ハッシュにnameキーがあれば出力。標準出力にはない。
  print " #{file_hash[:name].ljust(max_width, ' ')}" if file_hash.key?(:name)
  puts
end

def output_multi_line_l_option(files)
  total = { lines: 0, name: 'total' }
  max_width = 0
  # すべてのファイルのハッシュの要素で一番長い文字数を計算
  max_width = calc_max_width_files(files)

  # ファイルごとにファイル情報を出力
  files.each do |file_hash|
    total[:lines] += file_hash[:lines].to_i
    output_single_line_l_option(file_hash, max_width)
  end
  output_single_line_l_option(total, max_width) # 最後にtotal出力
end

# その他メソッド
# ファイルの情報が入ったハッシュから一番長い文字列を取得
def calc_max_width(file)
  max_width = 0
  file.each do |_key, value|
    max_width = value.to_s.length + 1 if value.to_s.length >= max_width
  end
  max_width
end

def calc_max_width_files(files)
  # 複数ファイルが入ったハッシュの要素で一番長い文字数を計算
  max_width = 0
  files.each do |hash|
    max_width = calc_max_width(hash) + 1 if calc_max_width(hash) > max_width
  end
  max_width
end

main
