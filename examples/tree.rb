require './lib/psd'

psd = PSD.new('/Users/ryanlefevre/Downloads/Features.psd')
psd.parse!

pp psd.tree.to_hash