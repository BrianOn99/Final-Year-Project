#!/usr/bin/ruby
# This script parse a Towhee stdout, and generate a tcl script to set
# box dimension for each frame.  Designed to work with VMD.

require_relative "Parse_Towhee"

parser = Parse_Towhee.new(open(ARGV[0]))

frame = 0
parser.lens.each do |len|
  puts "pbc set {#{len} #{len} #{len}} -first #{frame} -last #{frame}"
  frame = frame + 1
end
