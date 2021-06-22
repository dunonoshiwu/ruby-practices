#!/usr/bin/env ruby
require 'optparse'

def main
  options = ARGV.getopts('l')
  file_info = \
    if ARGV.any?
      file_info_put_into_array
    elsif File.pipe?($stdin) # 標準入力がある場合
      file = $stdin.read # file変数に標準入力を代入
      file_array = [] # 標準入力のファイル情報も配列に入れる
      file_array << input_file_info(file)
      file_array
    else
      exit # 引数、標準入力がなければ終了
    end
  l_option = options['l'] ? true : false # オプションあればyes,なければno
  output_file_info(file_info, l_option)
end

def input_file_info(file, file_name = nil)
  {
    lines: file.scan("\n").size,
    words: file.split(/\s+/).size,
    bytes: file.bytesize,
    name: (File.basename(file_name) unless file_name.nil?)
  }
end

def file_info_put_into_array
  file_info = [] # 複数のハッシュ情報を配列で保持する
  ARGV.each do |f|
    file = File.read(f)
    file_name = f
    file_info << input_file_info(file, file_name)
  end
  file_info
end

def output_single_line(file_hash, l_option)
  print file_hash[:lines].to_s.rjust(8)
  unless l_option # lオプションなければ単語数・バイト数も表示する
    print file_hash[:words].to_s.rjust(8)
    print file_hash[:bytes].to_s.rjust(8)
  end
  print " #{file_hash[:name].to_s.ljust(8)}" if file_hash.key?(:name)
  puts
end

def output_file_info(file_info, l_option)
  if file_info.length >= 2 # ファイル情報が2つ以上の場合
    total = { lines: 0, words: 0, bytes: 0, name: 'total' }
    file_info.each do |file|
      total[:lines] += file[:lines].to_i
      total[:words] += file[:words].to_i
      total[:bytes] += file[:bytes].to_i
      output_single_line(file, l_option)
    end
    output_single_line(total, l_option) # 最後にトータルを1行出力
  else
    output_single_line(file_info[0], l_option)
  end
end

main
