require './lib/psd'
require 'terminal-table'
require 'colorize'

file = ARGV[0] || 'examples/images/example.psd'
layer_comp = ARGV[1]

psd = PSD.new(file)
psd.parse!

tree = layer_comp ? psd.tree.filter_by_comp(layer_comp) : psd.tree
  
title = "#{File.basename(file)} / #{layer_comp || "Last Document State"}"
header = ["Visible?", "Position", "Dimensions", "Path"]
rows = tree.descendants.map do |node|
  [
    node.visible?.to_s.colorize(node.visible? ? :green : :red), 
    "(#{node.left}, #{node.top})",
    "#{node.width}x#{node.height}",
    { value: node.path, width: 90 }
  ]
end

table = Terminal::Table.new rows: rows, headings: header, title: title

puts table