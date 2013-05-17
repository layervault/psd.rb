require './lib/psd'

module PSDOutput
  def self.print_folders(folder, prefix = [])
    folder[:layers].each do |layer|
      puts prefix.join("") + layer[:name]
      if layer.is_a?(Hash)
        prefix.push "-> "
        self.print_folders(layer, prefix)
        prefix.pop
      end
    end
  end
end

psd = PSD.new('examples/images/example.psd')
psd.parse!
psd.layers_with_structure
# PSDOutput.print_folders psd.layers_with_structure