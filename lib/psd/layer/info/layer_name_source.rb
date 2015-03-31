require 'psd/layer_info'

class PSD
  class LayerNameSource < LayerInfo
    def self.should_parse?(key)
      key == 'lnsr'
    end
    
    attr_reader :id
    
    def parse
      @id = @file.read_string(4)
      return self
    end
  end
end