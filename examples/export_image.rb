require 'benchmark'
require './lib/psd'
require 'RMagick'

file = ARGV[0] || 'examples/images/example.psd'

results = Benchmark.measure "Image exporting" do
  psd = PSD.new(file)
  psd.image.save_as_png 'output.png'
end

puts "Using PSD.rb:\n"
puts Benchmark::CAPTION
puts results.to_s

results = Benchmark.measure "RMagick" do
  rm = Magick::Image.read(file).first
  rm.write "output2.png"
end

puts "Using RMagick:\n"
puts Benchmark::CAPTION
puts results.to_s