require 'benchmark'
require 'pp'
require './lib/psd'

file = ARGV[0] || '/Users/ryanlefevre/LayerVault/Turtleworks/Directory Page.psd'

results = Benchmark.measure "Image exporting" do
  psd = PSD.new(file, parse_layer_images: true)
  psd.parse!

  png = psd.tree.to_png
  puts "#{png.width}x#{png.height} - #{png.pixels.length}"
  png.save('./output.png')
end

puts Benchmark::CAPTION
puts results.to_s