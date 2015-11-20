require 'psd/layer_info'

class PSD
  class Posterize < LayerInfo
    def self.should_parse?(key)
      key == 'post'
    end

    attr_reader :levels

    def parse
      @levels = @file.read_short
      @file.seek 2, IO::SEEK_CUR # Padding?
    end
  end
end
