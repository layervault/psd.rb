require './lib/psd'

psd = PSD.new('examples/images/example.psd')
psd.parse!

psd.tree.children_at_path("Version A").first.children.first.image.save "Text.png"
puts "Done!"