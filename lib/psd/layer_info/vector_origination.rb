require 'psd/layer_info'

class PSD
  class VectorOrigination < LayerInfo
    def self.should_parse?(key)
      key == 'vogk'
    end

    def parse
      @file.seek 8, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end
  end
end