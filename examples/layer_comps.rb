require 'pp'
require './lib/psd'

file = ARGV[0] || '/Users/ryanlefevre/LayerVault/Turtleworks/Directory Page.psd'
psd = PSD.new(file)
psd.parse!

pp psd.layer_comps