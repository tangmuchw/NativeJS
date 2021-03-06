#!/usr/bin/env ruby

src_dir    = './src'
ext_dir    = './src/ext'
build_dir  = './build'
build_name = 'native'

# grab the files from the source folder

files = Dir.new(src_dir).entries.select { |f| f =~ /.*\.js/ }

# order by their requirements

# first will always be Basic.js

basic_name = 'Basic.js'

start_files = %w(
  Basic/Prototype
  Basic/Ajax
  Basic/Element 
  Framework 
  Function 
  Math 
  Number 
  Array 
  Enumerable 
  String 
  Interval 
  TimeInterval
)

end_files = %w(Finish)

start_files.map! { |n| n + '.js' }
end_files.map!   { |n| n + '.js' }

files.reject! { |name| 
  start_files.any? { |sf| sf == name } or end_files.any? { |ef| ef == name }
}

# add start_files at the front
start_files.reverse.each { |name| files.unshift name }
# append end files
end_files.each { |name| files.push name }

# grab a build name
build_file_name = build_dir + '/' + build_name + '.js'

out = File.open(build_file_name, 'w')

gitlog = `git log -n1`.split("\n")
build  = gitlog[0].split(" ")[1]
date   = gitlog[2][8,24]

puts "Building #{build_name}.js in #{build_dir}"

# write header
out.puts <<-HEADER
/**!
 * NativeJS, JavaScript Extensions
 * Build: #{build}
 * Date:  #{date}
 *
 * Copyright (c) 2001-2011 Ben Schuettler (Tharabas)
 */
HEADER

files.each { |filename|
  fullPath = src_dir + '/' + filename
  file = File.open(fullPath, 'r')
  filelog = `git log -n1 #{fullPath}`.split("\n")
  puts "+ #{filename.reverse[3,filename.length].reverse} (#{File.size(file)} bytes)"
  out.puts <<-FILEHEAD
/**
 * Name:    #{filename}
 FILEHEAD
 
  if filelog.length > 0 then
    out.puts <<-FILECOMMENTS
 * Version: #{filelog[2][8,24]}
 * Comment: #{filelog[4].strip}
    FILECOMMENTS
  else
    out.puts <<-FILECOMMENTS
 * Version: NEW
 * Comment: Not comitted yet
    FILECOMMENTS
  end
 
  out.puts " */"
  
  file.each_line { |line| out.puts(line) }
  out.puts(";")
}

out.close

# try to min it
#`jsmin #{build_file_name} > #{build_file_name.reverse[2,500].reverse + "min.js"}`

puts "--- DONE ---"