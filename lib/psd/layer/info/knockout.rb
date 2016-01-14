require 'psd/layer_info'

class PSD
  class Knockout < LayerInfo
    def self.should_parse?(key)
      key == 'knko'
    end

    MODES = [:shallow, :deep]

    attr_reader :enabled, :mode

    def parse
      val = @file.read_byte

      @enabled = val > 0
      @mode = MODES[val - 1]

      @file.seek 3, IO::SEEK_CUR
    end
  end
end
