require 'psd/layer_info'

class PSD
  class ObjectEffects < LayerInfo
    def self.should_parse?(key)
      ['lfx2', 'lmfx'].include? key
    end
    
    def parse
      version = @file.read_int
      descriptor_version = @file.read_int

      @data = Descriptor.new(@file).parse
    end
  end
end
