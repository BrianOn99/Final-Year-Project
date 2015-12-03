#!/usr/bin/ruby

require_relative "Parse_Towhee"
require_relative "Parse_LAMMPS"

avg_sacle = (ARGV[2] == "smooth" ? 200 : 1)
if ARGV[0] == "lammps"
  avg_sacle /= 2
end
avg_num = 1 * avg_sacle

parser = case ARGV[0]
when "towhee"
  Parse_Towhee.new(open(ARGV[1]))
when "lammps"
  Parse_LAMMPS.new(open(ARGV[1]))
else
  raise "unknown input format"
end

(avg_num...parser.steps.size).each do |i|
  avg = (parser.vols[i-avg_num, avg_num].reduce :+) / avg_num
  puts "%d %f" % [parser.steps[i], avg]
end
