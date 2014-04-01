require './lib/psd'
require 'terminal-table'

file = ARGV[0] || 'examples/images/example.psd'
layer_comp = ARGV[1]

psd = PSD.new(file)
psd.parse!

tree = psd.tree
tree = tree.filter_by_comp(layer_comp) if layer_comp

header = ["Visible?", "Path"]
rows = tree.descendants.map { |node| [node.visible?, node.path] }
table = Terminal::Table.new rows: rows, headings: header

puts table