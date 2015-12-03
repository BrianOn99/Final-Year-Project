#!/usr/bin/ruby

MOLECULE = [[0,0,0], [1.53,0,0], [2.1,1.42,0]]

def process_coord(coords)
  coords.select {|x| x.chomp.size != 0 }
        .each_slice(3) do |mol|
    cols = mol[0].split
    first_atom = cols[4,3].map {|x| x.to_f }
    trans = first_atom.map {|x| x*1.35 }
    scaled_mol = MOLECULE.map {|atom| (0..2).map {|i| atom[i] + trans[i] }}
    (0..2).each do |i|
      coord_frag = "%f %f %f" % scaled_mol[i]
      yield (mol[i].split[0..3] + [coord_frag] + mol[i].split[7..9]).join(" ")
    end
  end
end

infile = open(ARGV[0], 'r')

while line = infile.gets
  if line.start_with?("Atoms")
    puts line
    coords = []
    loop do
      line = infile.gets
      break if line.start_with? "Velocities"
      coords << line
    end
    puts ""
    process_coord(coords) do |modline|
      puts modline
    end
    puts ""
  end
  puts line
end
