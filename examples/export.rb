require './lib/psd'

psd = PSD.new('examples/images/example.psd')
psd.parse!

psd.tree.children.last.children.last.top = 200
psd.export "./test.psd"