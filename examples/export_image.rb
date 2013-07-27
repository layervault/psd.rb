require './lib/psd'

psd = PSD.new('examples/images/example.psd')
psd.parse!

psd.image.save_as_png 'output.png'
puts "Flattened image exported to ./output.png"