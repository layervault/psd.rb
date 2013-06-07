require 'benchmark'
require './lib/psd'

psd = nil
results = Benchmark.measure "PSD parsing" do
  # psd = PSD.new('spec/files/example.psd')
  # psd = PSD.new('test.psd')
  psd = PSD.new('./examples/images/example.psd')
  psd.parse!
end

puts "\nVisible Layers:\n===================="
psd.layers.each do |layer|
  next if layer.folder? || layer.hidden?

  puts "Name: #{layer.name}"
  puts "Position: top = #{layer.top}, left = #{layer.left}"
  puts "Size: width = #{layer.width}, height = #{layer.height}"
  puts "Mask: width = #{layer.mask.width}, height = #{layer.mask.height}"
  puts "Reference point: #{layer.ref_x}, #{layer.ref_y}"

  puts ""
end

puts "\nPSD Info:\n===================="
puts "#{psd.width}x#{psd.height} #{psd.header.mode_name}"
puts "#{psd.resources.size} resources parsed"
puts "#{psd.layers.size} layers, #{psd.folders.size} folders"

puts "\nBenchmark Results (seconds):\n===================="
puts " "*7 + Benchmark::CAPTION
puts "parse: " + results.to_s