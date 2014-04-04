require 'lib/psd/layer_info'

class PSD
  class ObjectEffects < LayerInfo
    def self.should_parse?(key)
      key == 'lfx2'
    end
    
    def parse
      version = @file.read_int
      descriptor_version = @file.read_int

      @data = Descriptor.new(@file).parse

      return self
    end
  end
end