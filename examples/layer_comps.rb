require 'benchmark'
require 'fileutils'
require 'pp'
require 'psd'

file = ARGV[0] || 'examples/images/example.psd'
FileUtils.mkdir_p('./output')

results = Benchmark.measure "Image exporting" do
  psd = PSD.new(file, parse_layer_images: true)
  psd.parse!

  psd.layer_comps.each do |comp|
    puts "Saving #{comp[:name]} - #{comp[:id]}"
    psd.tree
      .filter_by_comp(comp[:id])
      .save_as_png("./output/#{comp[:name]}.png")
  end
  # psd.tree.filter_by_comp('1 empty + prepopulated').save_as_png('./output.png')
end

puts Benchmark::CAPTION
puts results.to_s