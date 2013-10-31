require 'pp'
require './lib/psd'

file = ARGV[0] || '/Users/ryanlefevre/LayerVault/Pillocks/squares.psd'
psd = PSD.new(file, parse_layer_images: true)
psd.parse!

# pp psd.layer_comps
# psd.tree.filter_by_comp('Layer Comp 3').save_as_png('./output.png')
# puts png.width
# puts png.height
# puts png.pixels.size

psd.tree.save_as_png('./output.png')