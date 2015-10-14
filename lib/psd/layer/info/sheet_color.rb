require 'psd/layer_info'

class PSD
  # This is the color label for a group/layer. Not sure why Adobe
  # refers to it as the "Sheet Color".
  class SheetColor < LayerInfo
    def self.should_parse?(key)
      key == 'lclr'
    end

    COLORS = [
      :no_color,
      :red,
      :orange,
      :yellow,
      :green,
      :blue,
      :violet,
      :gray
    ]

    def parse
      # Only the first entry is used, the rest are always 0.
      @data = [
        @file.read_short,
        @file.read_short,
        @file.read_short,
        @file.read_short
      ]
    end

    def color
      COLORS[@data[0]]
    end
  end
end
