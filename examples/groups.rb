require './lib/psd'
require 'pp'

psd = PSD.new('examples/images/example.psd')
psd.parse!
pp psd.tree.to_hash