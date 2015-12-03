#!/usr/bin/ruby

lineno = ARGV[0].to_i
pdb_files = ARGV[1..-1]

Dir.mkdir "changed_pdb"

pdb_files.each do |fname|
  f = open(fname)
  out = open("changed_pdb/#{fname}", "w")
  f.each_line do |line|
    if f.lineno % lineno == 0
      line.sub! "H ", "HO"
    end
    out.puts line
  end
end
