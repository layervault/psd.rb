require 'psd/layer_info'

class PSD
  class ColorBalance < LayerInfo
    def self.should_parse?(key)
      key == 'blnc'
    end

    attr_reader :shadows, :midtones, :highlights, :preserve_luminosity

    def parse
      @shadows, @midtones, @highlights = 3.times.map do
        {
          cyan_red: @file.read_short,
          magenta_green: @file.read_short,
          yellow_blue: @file.read_short
        }
      end

      @preserve_luminosity = @file.read_short > 0
    end
  end
end
