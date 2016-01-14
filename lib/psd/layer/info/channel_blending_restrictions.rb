require 'psd/layer_info'

class PSD
  class ChannelBlendingRestrictions < LayerInfo
    def self.should_parse?(key)
      key == 'brst'
    end

    MODES = {
      'RGBColor' => ['R', 'G', 'B'],
      'CMYKColor' => ['C', 'M', 'Y', 'K']
    }

    attr_reader :restricted_channels, :restricted_channels_by_letter

    def parse
      @restricted_channels = []
      @restricted_channels_by_letter = []

      (@length / 4).times do
        channel = @file.read_int
        @restricted_channels << channel
        @restricted_channels_by_letter << MODES[@layer.header.mode_name][channel]
      end
    end
  end
end
