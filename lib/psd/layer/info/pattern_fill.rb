require 'psd/layer_info'

class PSD
  class PatternFill < LayerInfo
    def self.should_parse?(key)
      key == 'PtFl'
    end

    def parse
      # Version
      @file.seek 4, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end
  end
end
