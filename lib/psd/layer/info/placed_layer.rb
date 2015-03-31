require 'psd/layer_info'

class PSD
  class PlacedLayer < LayerInfo
    def self.should_parse?(key)
      key == 'SoLd'
    end

    def parse
      # Useless id/version info
      @file.seek 12, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end
  end
end