require './lib/psd'

psd = PSD.new('/Users/ryanlefevre/Downloads/Features.psd')
psd.parse!

pp psd.tree.children_at_path('content/File Support').first.to_hash