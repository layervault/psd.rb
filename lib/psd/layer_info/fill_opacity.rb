require 'lib/psd/layer_info'

class PSD
  class FillOpacity < LayerInfo
    def self.should_parse?(key)
      key == 'iOpa'
    end

    attr_reader :value

    def parse
      @value = @file.read_byte.to_i
    end
  end
end