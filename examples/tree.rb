require './lib/psd'
require 'terminal-table'

file = ARGV[0] || 'examples/images/example.psd'
psd = PSD.new(file)
psd.parse!

header = ["Visible?", "Path"]
rows = psd.tree.descendants.map { |node| [node.visible?, node.path] }
table = Terminal::Table.new rows: rows, headings: header

puts table