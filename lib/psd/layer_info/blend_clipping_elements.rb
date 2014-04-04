require 'lib/psd/layer_info'

class PSD
  class BlendClippingElements < LayerInfo
    def self.should_parse?(key)
      key == 'clbl'
    end

    attr_reader :enabled
    def parse
      @enabled = @file.read_boolean
      @file.seek 3, IO::SEEK_CUR
    end
  end
end