require 'benchmark'
require './lib/psd'

file = ARGV[0] || 'examples/images/example.psd'
psd = PSD.new(file)

results = Benchmark.measure "Image exporting" do
  psd.image.save_as_png 'output.png'
end

puts "Flattened image exported to ./output.png\n"
puts Benchmark::CAPTION
puts results.to_s