require 'benchmark'
require 'pp'
require './lib/psd'

file = ARGV[0] || '/Users/ryanlefevre/LayerVault/Turtleworks/Directory Page.psd'

results = Benchmark.measure "Image exporting" do
  psd = PSD.new(file, parse_layer_images: true)
  psd.parse!

  psd.tree.save_as_png('./output.png')
end

puts Benchmark::CAPTION
puts results.to_s