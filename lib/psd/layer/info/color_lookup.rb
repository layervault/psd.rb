require 'psd/layer_info'

class PSD
  class ColorLookup < LayerInfo
    def self.should_parse?(key)
      key == 'clrL'
    end

    def parse
      @file.seek 6, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end
  end
end
