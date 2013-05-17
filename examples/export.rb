require './lib/psd'

psd = PSD.new('examples/images/example.psd')
psd.parse!

psd.tree.children.last.children[0].lock_to_origin
psd.export "./test.psd"