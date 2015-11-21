require 'psd/layer_info'

class PSD
  class Threshold < LayerInfo
    def self.should_parse?(key)
      key == 'thrs'
    end

    attr_reader :level

    def parse
      @level = @file.read_short
      @file.seek 2, IO::SEEK_CUR # Padding?
    end
  end
end
