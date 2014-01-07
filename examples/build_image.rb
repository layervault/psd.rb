require 'benchmark'
require 'pp'
require './lib/psd'

file = ARGV[0] || '/Users/ryanlefevre/LayerVault/Turtleworks/Directory Page.psd'

results = Benchmark.measure "Image exporting" do
  psd = PSD.new(file)
  psd.parse!

  #psd.tree.children_with_path('Ellipse 1').first.save_as_png('./output.png')
  psd.tree.save_as_png('./output.png')
end

puts Benchmark::CAPTION
puts results.to_s