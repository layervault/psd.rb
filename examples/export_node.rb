require './lib/psd'

psd = PSD.new('/Users/ryanlefevre/Downloads/c7d9151aa6bc8511124b161e862f87c1.psd')
psd.parse!


psd.tree.children_at_path(["LIST VIEW screen", "Tabbar", "Tab Bar", "icons", "mysunbelt-icon@2x.png"]).first.save_as_png("./output.png")