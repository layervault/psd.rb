require 'pp'
require './lib/psd'

file = ARGV[0] || '/Users/ryanlefevre/LayerVault/Turtleworks/Directory Page.psd'
psd = PSD.new(file)
psd.parse!

# pp psd.layer_comps
# psd.tree.filter_by_comp('Layer Comp 3').save_as_png('./output.png')
# puts png.width
# puts png.height
# puts png.pixels.size

# psd.tree.children_at_path('left/people/Layer 12').first.save_as_png('./output.png')
pp psd.tree.children_at_path('left/people/Layer 12').first.to_hash
pp psd.tree.children_at_path('left/people/Rounded Rectangle 2 copy').first.to_hash