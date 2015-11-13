require 'psd/layer_info'

class PSD
  class ChannelMixer < LayerInfo
    def self.should_parse?(key)
      key == 'mixr'
    end

    attr_reader :monochrome, :color

    def parse
      @file.seek 2, IO::SEEK_CUR

      @monochrome = @file.read_short > 0

      @color = 4.times.map do
        {
          red_cyan: @file.read_short,
          green_magenta: @file.read_short,
          blue_yellow: @file.read_short,
          black: @file.read_short,
          constant: @file.read_short
        }
      end
    end
  end
end
