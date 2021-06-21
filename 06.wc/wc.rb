#!/usr/bin/env ruby
require 'optparse'

def main
  options = ARGV.getopts('l')
  file_info = \
    if ARGV.any?
      if ARGV.size == 1 # 引数のファイルが１つの場合
        file = File.read(ARGV[0]) # ファイルの内容をfile変数に代入
        input_file_info(file, ARGV[0]) # ファイル内容とファイル名を渡す
      else
        input_multi_file_info # 引数にファイル名が複数の場合
      end
    elsif File.pipe?($stdin) # 標準入力がある場合
      file = $stdin.read # file変数に標準入力を代入
      input_file_info(file)
    else
      exit # 引数、標準入力がなければ終了
    end
  l_option = options['l'] ? 'yes' : 'no' # オプションあればyes,なければno
  output_file_info(file_info, l_option)
end

def input_file_info(file, file_name = nil)
  file_info = {}
  file_info[:lines] = file.scan("\n").size # 行数
  file_info[:words] = file.split(/\s+/).size # 単語数
  file_info[:bytes] = file.bytesize # バイトサイズ
  file_info[:name] = File.basename(file_name) unless file_name.nil?
  file_info
end

def input_multi_file_info
  file_info = [] # 複数のハッシュ情報を配列で保持する
  ARGV.each do |f|
    file = File.read(f)
    file_name = f
    file_info << input_file_info(file, file_name)
  end
  file_info
end

def output_single_line(file_hash, l_option)
  case l_option
  when 'yes'
    print file_hash[:lines].to_s.rjust(8)
    print " #{file_hash[:name].to_s.ljust(8)}" if file_hash.key?(:name)
    puts
  when 'no'
    print file_hash[:lines].to_s.rjust(8)
    print file_hash[:words].to_s.rjust(8)
    print file_hash[:bytes].to_s.rjust(8)
    print " #{file_hash[:name].to_s.ljust(8)}" if file_hash.key?(:name)
    puts
  end
end

def output_file_info(file_info, l_option)
  if file_info.instance_of?(Array) # 引数が配列の場合（ファイル名が複数の場合）
    total = { lines: 0, words: 0, bytes: 0, name: 'total' }
    file_info.each do |file|
      total[:lines] += file[:lines].to_i
      total[:words] += file[:words].to_i
      total[:bytes] += file[:bytes].to_i
      output_single_line(file, l_option)
    end
    output_single_line(total, l_option) # 最後にトータルを1行出力
  else
    output_single_line(file_info, l_option)
  end
end

main
