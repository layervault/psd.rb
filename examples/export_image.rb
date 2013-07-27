require 'benchmark'
require './lib/psd'

psd = PSD.new('examples/images/example.psd')

results = Benchmark.measure "Image exporting" do
  psd.image.save_as_png 'output.png'
end

puts "Flattened image exported to ./output.png\n"
puts Benchmark::CAPTION
puts results.to_s