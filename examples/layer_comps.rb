require 'pp'
require './lib/psd'

file = ARGV[0] || 'examples/images/comp-example.psd'
psd = PSD.new(file, parse_layer_images: true)
psd.parse!

# pp psd.layer_comps
psd.tree.filter_by_comp('Layer Comp 3').save_as_png('./output.png')
# puts png.width
# puts png.height
# puts png.pixels.size

# layer = psd.tree.children_at_path('Rectangle 3').first
# layer.image.save_as_png('./output.png')