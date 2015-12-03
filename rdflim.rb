#!/usr/bin/ruby
# find when the radial distribution function reaches mean value

class Analyzer
  FRAME_REGEX = /\{(.*?)\} \{(.*?)\}.*/

  def initialize(input)
    @bins, @rdfs = extract(input)
    @mean = @rdfs[-1]
  end

  def extract(input)
    rdfs = input.collect do |frame|
      frame =~ FRAME_REGEX
      $2.split.collect {|x| x.to_f }
    end
    [$1.split.collect {|x| x.to_f }, rdfs]
  end

  def rms(frame, selects)
    sq_sum = selects.reduce(0) do |memo, i|
      memo + (frame[i] - @mean[i])**2
    end
    (sq_sum / selects.size)**0.5
  end

  def trend_data(selects)
    @rdfs.each_with_index do |frame, i|
      yield i, rms(frame, selects)
    end
  end

  def find_lim(threshold, selects)
    @rdfs.each_with_index do |frame, i|
      return i if rms(frame, selects) < threshold
    end
  end
end

lim = ARGV[1].to_f
selects = if ARGV.size > 2
            ARGV[2].split(",").collect{|x| x.to_i }
          else
            [16,17,18,19,20,21,23,25,29,33]
          end

finder = Analyzer.new(open(ARGV[0]))

finder.trend_data(selects) do |frame_i, data|
  puts "#{frame_i} #{data}"
end
puts finder.find_lim(lim, selects)
