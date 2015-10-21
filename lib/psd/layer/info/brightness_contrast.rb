require 'psd/layer_info'

class PSD
  # NOTE: this only has the correct values when the "Use Legacy"
  # checkbox is checked. If the 'CgEd' info key is present, these
  # values will all be 0. Use that info block instead.
  class BrightnessContrast < LayerInfo
    def self.should_parse?(key)
      key == 'brit'
    end

    attr_reader :brightness, :contrast, :mean_value, :lab_color

    def parse
      @brightness = @file.read_short
      @contrast = @file.read_short
      @mean_value = @file.read_short
      @lab_color = @file.read_byte
    end
  end
end
