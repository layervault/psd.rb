require 'psd/layer_info'

class PSD
  class VectorStrokeContent < LayerInfo
    def self.should_parse?(key)
      key == 'vscg'
    end

    attr_reader :key
    
    def parse
      key = @file.read_string(4)
      version = @file.read_int
      @data = Descriptor.new(@file).parse
    end
  end
end