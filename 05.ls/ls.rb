#!/usr/bin/env ruby
require 'etc'
require 'time'
require 'optparse'

def main
  options = ARGV.getopts('a', 'l', 'r')

  # 上からそれぞれのオプションの処理を実行、なければオプション無しの処理
  files = if options['a']
            input_list_including_hidden_files
          else
            input_list
          end

  files = reverse_the_array(files) if options['r']

  if options['l']
    output_list_in_long_format(files)
  else
    output_list(files)
  end
end

# ファイルのパスを配列にいれる
def input_list
  files = []
  current_directory = Dir.pwd
  Dir.glob('*') do |file|
    files << File.join(current_directory, file)
  end
  files
end

# 隠しファイルも含めたすべてのパスを配列に入れる
def input_list_including_hidden_files
  files = []
  current_directory = Dir.pwd
  Dir.glob('*', File::FNM_DOTMATCH) do |file|
    files << File.join(current_directory, file)
  end
  files
end

# 列を指定して表示する
def output_list(files)
  # 一番長いファイル名の長さを取得
  file_names = files.map { |x| File.basename(x) }
  max_width_name = file_names.max_by(&:length)
  max_width = max_width_name.length
  # 3列を基準に並べる
  col = 3
  files_sum = files.size
  quotient, remainder = files_sum.divmod(col)
  quotient += 1 if remainder != 0
  x = 0
  y = 0
  quotient.times do # 縦の表示
    y = x
    col.times do # 横の表示
      path = files[y].to_s
      file_name = File.basename(path)
      # 一番長いファイル名に合わせてスペース
      print "#{file_name}#{' ' * (max_width - file_name.length)} "
      y += quotient # 商の数だけ要素を飛び飛びで取得
    end
    puts # 改行
    x += 1 # 縦の要素の順番をリセット
  end
end

# 詳細に表示する
def output_list_in_long_format(files)
  # 一番長いファイルサイズの桁数を取得
  files_size = files.map { |x| File::Stat.new(x).size.to_s }
  max_width_size = files_size.max_by(&:length)
  max_width = max_width_size.length
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
