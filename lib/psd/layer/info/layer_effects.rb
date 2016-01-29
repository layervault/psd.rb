require 'psd/layer_info'

class PSD
  class LayerEffects < LayerInfo
    def self.should_parse?(key)
      key == 'lfxs'
    end

    def parse
      version = @file.read_int
      descriptor_version = @file.read_int

      @data = Descriptor.new(@file).parse
    end
  end
end
