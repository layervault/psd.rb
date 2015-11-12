require 'psd/layer_info'

class PSD
  class PhotoFilter < LayerInfo
    def self.should_parse?(key)
      key == 'phfl'
    end

    attr_reader :color, :density, :preserve_luminosity

    def parse
      version = @file.read_short

      case version
      when 2 then parse_version_2
      when 3 then parse_version_3
      else return
      end

      @density = @file.read_int
      @preserve_luminosity = @file.read_boolean
    end

    private

    def parse_version_2
      color_space = @file.read_short
      color_components = 4.times.map { @file.read_short }

      @color = {
        color_space: Color::COLOR_SPACE[color_space],
        components: color_components
      }
    end

    def parse_version_3
      @color = {
        x: @file.read_int >> 8,
        y: @file.read_int >> 8,
        z: @file.read_int >> 8
      }
    end
  end
end
