require 'lib/psd/layer_info'

class PSD
  class SolidColor < LayerInfo
    def self.should_parse?(key)
      key == 'SoCo'
    end

    def parse
      @file.seek 4, IO::SEEK_CUR
      @data = Descriptor.new(@file).parse
    end

    def color
      ChunkyPNG::Color.rgb(r, g, b)
    end

    def r
      @r ||= color_data['Rd  '].round
    end

    def g
      @g ||= color_data['Grn '].round
    end

    def b
      @b ||= color_data['Bl  '].round
    end

    private

    def color_data
      @data['Clr ']
    end
  end
end