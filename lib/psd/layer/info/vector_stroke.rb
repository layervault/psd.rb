require 'psd/layer_info'

class PSD
  class VectorStroke < LayerInfo
    def self.should_parse?(key)
      key == 'vstk'
    end

    def parse
      version = @file.read_int
      @data = Descriptor.new(@file).parse
    end
  end
end