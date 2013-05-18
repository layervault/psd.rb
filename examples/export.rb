require './lib/psd'

psd = PSD.new('examples/images/example.psd')
psd.parse!

# puts psd.tree.children.last.children[1].left
psd.tree.children.last.children[1].lock_to_origin
# puts psd.tree.children.last.children[1].left
# psd.tree.children.each(&:hide!)
# psd.tree.children.first.show!
psd.export "./test.psd"