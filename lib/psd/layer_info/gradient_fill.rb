require 'psd/layer_info'

class PSD
  class GradientFill < LayerInfo
    def self.should_parse?(key)
      key == 'GdFl'
    end

    def parse
      @file.seek 4, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end
  end
end
