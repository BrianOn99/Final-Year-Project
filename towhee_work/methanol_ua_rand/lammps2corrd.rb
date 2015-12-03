#!/usr/bin/ruby

infile = open(ARGV[0], 'r')
infile.drop_while { |line| !line.start_with?("Atom") }
      .drop_while { |line| line !~ /[1-9].*/ }
      .each do |line|
  break if line.chomp.size ==0
  cols = line.split
  puts cols[4,3].join("  ")
end
