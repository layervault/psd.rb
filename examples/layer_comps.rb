require 'pp'
require './lib/psd'

file = ARGV[0] || 'examples/images/comp-example.psd'
psd = PSD.new(file)
psd.parse!

pp psd.layer_comps
pp psd.tree.filter_by_comp('Comp 3').to_hash