require './lib/psd'

psd = PSD.new('/Users/ryanlefevre/LayerVault/Turtleworks/Conversation.psd')
psd.parse!

pp psd.tree.to_hash