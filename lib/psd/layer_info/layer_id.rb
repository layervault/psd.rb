require 'lib/psd/layer_info'

class PSD
  class LayerID < LayerInfo
    def self.should_parse?(key)
      key == 'lyid'
    end

    attr_reader :id

    def parse
      @id = @file.read_int
    end
  end
end