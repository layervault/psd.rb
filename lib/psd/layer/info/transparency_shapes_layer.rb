require 'psd/layer_info'

class PSD
  class TransparencyShapesLayer < LayerInfo
    def self.should_parse?(key)
      key == 'tsly'
    end

    attr_reader :enabled

    def parse
      @enabled = @file.read_byte == 1
      @file.seek 3, IO::SEEK_CUR
    end
  end
end
