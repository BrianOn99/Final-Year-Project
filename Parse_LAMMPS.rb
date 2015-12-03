#!/usr/bin/ruby

class Parse_LAMMPS
  attr_reader(:steps, :vols)
  TIME_HEADER = "ITEM: TIMESTEP"
  VOL_HEADER = "ITEM: BOX BOUNDS"

  def initialize(input)
    @steps = []
    @vols = []

    while line = input.gets
      if line.start_with? TIME_HEADER
        time = input.gets.strip.to_i
      end
      if line.start_with? VOL_HEADER
        columns = input.gets.split
        len = columns[1].to_f - columns[0].to_f
        steps.push(time)
        vols.push(len**3)
      end
    end
  end

  def lens
    vols.collect {|vol| vol**(1.0/3) }
  end
end
