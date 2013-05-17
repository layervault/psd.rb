require './lib/psd'

psd = PSD.new('examples/images/example.psd')
psd.export "./test.psd"