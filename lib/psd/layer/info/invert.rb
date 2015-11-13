require 'psd/layer_info'

class PSD
  class Invert < LayerInfo
    def self.should_parse?(key)
      key == 'nvrt'
    end

    attr_reader :inverted

    def parse
      # There is no data. The presence of this info block is
      # all that's provided.
      @inverted = true
    end
  end
end
