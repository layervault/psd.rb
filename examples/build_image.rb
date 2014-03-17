require 'benchmark'
require 'pp'
require 'psd'

file = ARGV[0] || 'biglogo.psd'

results = Benchmark.measure "Image exporting" do
  psd = PSD.new(file)
  psd.parse!

  # psd.tree.save_as_png('./output.png')
  layer = psd.tree.children.first
  pp puts layer.vector_mask.paths.map(&:to_hash)
  layer.save_as_png('./output.png')
end

puts Benchmark::CAPTION
puts results.to_s