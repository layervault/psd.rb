require './lib/psd'

psd = PSD.new('examples/images/example.psd')
psd.parse!

puts "#{psd.width}x#{psd.height} #{psd.header.mode_name}"
puts "#{psd.resources.size} resources parsed"

puts "\nVisible layers:\n===================="
psd.layers.each do |layer|
  next if layer.folder? || layer.hidden?

  puts "Name: #{layer.name}"
  puts "Position: top = #{layer.top}, left = #{layer.left}"
  puts "Size: width = #{layer.width}, height = #{layer.height}"

  puts ""
end