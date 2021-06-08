#!/usr/bin/env ruby
require 'etc'
require 'time'
require 'optparse'

def main
  options = ARGV.getopts('a', 'l', 'r')

  # 上からそれぞれのオプションの処理を実行、なければオプション無しの処理
  files = if options['a']
            input_list('a')
          else
            input_list('no')
          end

  files = reverse_the_array(files) if options['r']

  if options['l']
    output_list_in_long_format(files)
  else
    output_list(files)
  end
end

# ファイルのパスを配列にいれる
def input_list(arg)
  files = []
  current_directory = Dir.pwd
  option = arg == 'a' ? File::FNM_DOTMATCH : 0
  Dir.glob('*', option) do |file|
    files << File.join(current_directory, file)
  end
  files
end


# 列を指定して表示する
def output_list(files)
  # 一番長いファイル名の長さを取得
  file_names = files.map { |x| File.basename(x) }
  max_width_name = file_names.max_by(&:length).length + 1
  # 3列を基準に並べる
  col = 3
  files_sum = files.size
  quotient, remainder = files_sum.divmod(col)
  quotient += 1 if remainder != 0
  
  quotient.times do |x|
    file_names.each_slice(quotient) do |a| 
      # 縦の要素で一番多い文字数を取得。スペースのため+1
      max_width = a.map(&:length).max + 1
      print a[x].ljust(max_width,' ') unless a[x].instance_of?(NilClass)
    end
    puts
  end
end

# 詳細に表示する
def output_list_in_long_format(files)
  # 一番長いファイルサイズの桁数を取得
  files_size = files.map { |x| File::Stat.new(x).size.to_s }
  max_width = files_size.max_by(&:length).length + 1
  # total ブロック数を取得
  total = get_blocks(files)
  puts "total #{total}"

  # ファイル情報をリスト表示
  files.each do |e|
    element = File::Stat.new(e)
    statmode = element.mode.to_s(8)
    print ftype_to_sign(element.ftype)
    print judge_permissions(statmode[-3])
    print judge_permissions(statmode[-2])
    print judge_permissions(statmode[-1])
    print " #{element.nlink} "
    print "#{Etc.getpwuid(element.uid).name} "
    print "#{Etc.getgrgid(element.gid).name} "
    print "#{' ' * (max_width - element.size.to_s.length)}#{element.size} "
    print "#{element.mtime.strftime('%-m %-d %H:%M')} "
    puts File.basename(e)
  end
end

def get_blocks(files)
  total = 0
  files.each do |e|
    elem = File::Stat.new(e)
    total += elem.blocks
  end
  total
end

# 配列を逆にする
def reverse_the_array(files)
  files.reverse
end

def ftype_to_sign(ftype)
  {
    'fifo' => 'p',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'file' => '-',
    'link' => 'l',
    'blockSpecial' => 'b',
    'socket' => 's'
  }[ftype]
end

def judge_permissions(permission)
  {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[permission]
end

main
