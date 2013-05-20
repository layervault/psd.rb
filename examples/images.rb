require './lib/psd'

psd = PSD.new('examples/images/example.psd')
psd.parse!

psd.image.save "test.png"