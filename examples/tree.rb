require './lib/psd'

psd = PSD.new('/Users/ryanlefevre/LayerVault/Turtleworks/Directory Page.psd')
psd.parse!

pp psd.tree.to_hash