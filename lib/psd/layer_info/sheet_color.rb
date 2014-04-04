require 'lib/psd/layer_info'

class PSD
  class SheetColor < LayerInfo
    def self.should_parse?(key)
      key == 'lclr'
    end

    def parse
      @data = [
        @file.read_short,
        @file.read_short,
        @file.read_short,
        @file.read_short
      ]
    end
  end
end