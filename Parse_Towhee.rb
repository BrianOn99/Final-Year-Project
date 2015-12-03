#!/usr/bin/ruby
# Extract box dimension from towhee standard output
# Assume cubic box

class Parse_Towhee
  attr_reader(:steps, :vols)
  INFO_REGEX = /\s\d*? B:.*/
  DIM_REGEX = /Box idim hmatrix:.*/

  def initialize(input)
    @steps = []
    @vols = []

    input.each do |line|
      if line =~ DIM_REGEX
        dim = line.split[-3]
        steps.push(0)
        vols.push(dim.to_f**3)
        break
      end
    end

    input.each do |line|
      next if line !~ INFO_REGEX
      columns = line.split
      steps.push(columns[0].to_i)
      vols.push(columns[4].to_f)
    end
  end

  def lens
    vols.collect {|vol| vol**(1.0/3) }
  end
end
