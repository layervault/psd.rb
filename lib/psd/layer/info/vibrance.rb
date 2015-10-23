require 'psd/layer_info'

class PSD
  class Vibrance < LayerInfo
    def self.should_parse?(key)
      key == 'vibA'
    end

    def parse
      @file.seek 4, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end

    def vibrance
      @data['vibrance']
    end

    def saturation
      @data['Strt']
    end
  end
end
