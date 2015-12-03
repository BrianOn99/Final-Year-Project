#!/usr/bin/ruby

require_relative "Parse_Towhee"
require_relative "Parse_LAMMPS"

parser = case ARGV[0]
when "towhee"
  avg_num = 1000
  Parse_Towhee.new(open(ARGV[1]))
when "lammps"
  avg_num = 200
  Parse_LAMMPS.new(open(ARGV[1]))
else
  raise "unknown input format"
end

avg = (parser.vols[parser.steps.size-avg_num-1, avg_num].reduce :+) / avg_num
puts "%f" % [avg]
