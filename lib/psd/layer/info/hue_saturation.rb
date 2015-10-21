require 'psd/layer_info'

class PSD
  class HueSaturation < LayerInfo
    def self.should_parse?(key)
      key == 'hue2'
    end

    attr_reader :type, :colorization, :master, :range_values, :setting_values

    def parse
      # Version
      @file.seek 2, IO::SEEK_CUR

      @type = @file.read_byte == 0 ? :hue : :colorization

      # Padding byte
      @file.seek 1, IO::SEEK_CUR

      @colorization = {
        hue: @file.read_short,
        saturation: @file.read_short,
        lightness: @file.read_short
      }

      @master = {
        hue: @file.read_short,
        saturation: @file.read_short,
        lightness: @file.read_short
      }

      @range_values = []
      @setting_values = []

      6.times do
        @range_values << 4.times.map { @file.read_short }
        @setting_values << 3.times.map { @file.read_short }
      end
    end
  end
end
