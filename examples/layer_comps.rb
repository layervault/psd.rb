require 'benchmark'
require 'fileutils'
require 'pp'
require './lib/psd'

file = ARGV[0] || 'examples/images/example.psd'
layer_comp = ARGV[1]
FileUtils.mkdir_p('./output')

results = Benchmark.measure "Image exporting" do
  psd = PSD.new(file, parse_layer_images: true)
  psd.parse!

  if layer_comp
    puts "Saving #{layer_comp}"
    psd.tree.filter_by_comp(layer_comp).save_as_png("./output/#{layer_comp}.png")
  else
    psd.layer_comps.each do |comp|
      puts "Saving #{comp[:name]} - #{comp[:id]}"
      psd.tree
        .filter_by_comp(comp[:id])
        .save_as_png("./output/#{comp[:name]}.png")
    end
  end
end

puts Benchmark::CAPTION
puts results.to_s