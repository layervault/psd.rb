require 'fileutils'
require './lib/psd'

file = ARGV[0] || 'examples/images/example.psd'
psd = PSD.new(file, parse_layer_images: true)

psd.parse!

psd.tree.descendant_layers.each do |layer|
  path = layer.path.split('/')[0...-1].join('/')
  FileUtils.mkdir_p("output/#{path}")
  layer.image.save_as_png "output/#{layer.path}.png"
end